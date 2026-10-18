/// Matemática de fees da Uniswap v3, replicada a partir do contrato
/// `UniswapV3Pool`/`Position.sol` para calcular fees não reclamadas
/// diretamente a partir de campos do subgraph (sem precisar de simular um
/// `collect()` via RPC). Valores "X128" são fixed-point Q128: o número real
/// é `valor / 2^128`.
library;

final BigInt _q128 = BigInt.one << 128;
final BigInt _mask256 = (BigInt.one << 256) - BigInt.one;

/// Subtração "unchecked" de 256 bits: a Solidity deixa isto dar overflow e
/// voltar à volta (two's complement mod 2^256) de propósito — os valores de
/// feeGrowth são *desenhados* para serem lidos como diferenças módulo 2^256,
/// por isso replicar o wraparound é necessário, não um bug.
BigInt wrap256(BigInt value) => value.toUnsigned(256) & _mask256;

/// `feeGrowthInside` da posição no momento atual (fórmula de
/// `Tick.getFeeGrowthInside`).
BigInt feeGrowthInsideX128({
  required BigInt feeGrowthGlobalX128,
  required BigInt feeGrowthOutsideLowerX128,
  required BigInt feeGrowthOutsideUpperX128,
  required int currentTick,
  required int tickLower,
  required int tickUpper,
}) {
  final feeGrowthBelow = currentTick >= tickLower
      ? feeGrowthOutsideLowerX128
      : wrap256(feeGrowthGlobalX128 - feeGrowthOutsideLowerX128);

  final feeGrowthAbove = currentTick < tickUpper
      ? feeGrowthOutsideUpperX128
      : wrap256(feeGrowthGlobalX128 - feeGrowthOutsideUpperX128);

  return wrap256(
    wrap256(feeGrowthGlobalX128 - feeGrowthBelow) - feeGrowthAbove,
  );
}

/// Tokens em dívida (não reclamados) desde o último `collect`/update da
/// posição, em unidades inteiras do token (ainda sem dividir pelos decimais).
BigInt tokensOwed({
  required BigInt feeGrowthInsideX128,
  required BigInt feeGrowthInsideLastX128,
  required BigInt liquidity,
}) {
  final delta = wrap256(feeGrowthInsideX128 - feeGrowthInsideLastX128);
  return (delta * liquidity) ~/ _q128;
}

/// Combina as duas funções acima para as duas tokens de uma posição.
({BigInt owed0, BigInt owed1}) computeUnclaimedTokens({
  required BigInt feeGrowthGlobal0X128,
  required BigInt feeGrowthGlobal1X128,
  required BigInt feeGrowthOutsideLower0X128,
  required BigInt feeGrowthOutsideLower1X128,
  required BigInt feeGrowthOutsideUpper0X128,
  required BigInt feeGrowthOutsideUpper1X128,
  required BigInt feeGrowthInsideLast0X128,
  required BigInt feeGrowthInsideLast1X128,
  required BigInt liquidity,
  required int currentTick,
  required int tickLower,
  required int tickUpper,
}) {
  final inside0 = feeGrowthInsideX128(
    feeGrowthGlobalX128: feeGrowthGlobal0X128,
    feeGrowthOutsideLowerX128: feeGrowthOutsideLower0X128,
    feeGrowthOutsideUpperX128: feeGrowthOutsideUpper0X128,
    currentTick: currentTick,
    tickLower: tickLower,
    tickUpper: tickUpper,
  );
  final inside1 = feeGrowthInsideX128(
    feeGrowthGlobalX128: feeGrowthGlobal1X128,
    feeGrowthOutsideLowerX128: feeGrowthOutsideLower1X128,
    feeGrowthOutsideUpperX128: feeGrowthOutsideUpper1X128,
    currentTick: currentTick,
    tickLower: tickLower,
    tickUpper: tickUpper,
  );

  return (
    owed0: tokensOwed(
      feeGrowthInsideX128: inside0,
      feeGrowthInsideLastX128: feeGrowthInsideLast0X128,
      liquidity: liquidity,
    ),
    owed1: tokensOwed(
      feeGrowthInsideX128: inside1,
      feeGrowthInsideLastX128: feeGrowthInsideLast1X128,
      liquidity: liquidity,
    ),
  );
}

/// Converte uma quantidade inteira de token (unidades mínimas) para um
/// double em unidades humanas, dividindo pelos decimais do token.
double tokenAmountToDouble(BigInt rawAmount, int decimals) {
  if (decimals <= 0) return rawAmount.toDouble();
  final divisor = BigInt.from(10).pow(decimals);
  final whole = rawAmount ~/ divisor;
  final remainder = rawAmount.remainder(divisor);
  return whole.toDouble() + remainder.toDouble() / divisor.toDouble();
}

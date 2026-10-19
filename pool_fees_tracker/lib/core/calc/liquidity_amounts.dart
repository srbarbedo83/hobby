import 'dart:math' show pow;

/// Mesma fórmula do contrato `LiquidityAmounts.getAmountsForLiquidity` da
/// Uniswap (v3 e v4 partilham esta matemática — só a arquitetura à volta
/// mudou), mas em `double` em vez de Q64.96 fixed-point: suficiente para
/// mostrar um valor em USD no dashboard, não para liquidar on-chain.
///
/// `tick`, `tickLower`, `tickUpper` entram em ticks "crus" (sem ajuste de
/// decimais) — ao contrário de `priceAtTick`, que já ajusta pelos decimais
/// dos tokens para mostrar um preço legível. Os montantes devolvidos também
/// são "crus" (unidades mínimas do token, antes de dividir por 10^decimais —
/// usa [tokenAmountToDouble] depois, como no resto da app).
({double amount0, double amount1}) getAmountsForLiquidity({
  required double liquidity,
  required int tick,
  required int tickLower,
  required int tickUpper,
}) {
  if (liquidity <= 0 || tickUpper <= tickLower) {
    return (amount0: 0, amount1: 0);
  }

  final sqrtLower = _sqrtRatioAtTick(tickLower);
  final sqrtUpper = _sqrtRatioAtTick(tickUpper);
  final sqrtCurrent = _sqrtRatioAtTick(tick);

  if (tick <= tickLower) {
    return (
      amount0: liquidity * (1 / sqrtLower - 1 / sqrtUpper),
      amount1: 0,
    );
  }
  if (tick >= tickUpper) {
    return (amount0: 0, amount1: liquidity * (sqrtUpper - sqrtLower));
  }
  return (
    amount0: liquidity * (1 / sqrtCurrent - 1 / sqrtUpper),
    amount1: liquidity * (sqrtCurrent - sqrtLower),
  );
}

/// `sqrt(1.0001^tick)` — raiz quadrada do preço "cru" (token1 por token0,
/// sem ajuste de decimais) nesse tick.
double _sqrtRatioAtTick(int tick) => pow(1.0001, tick / 2.0).toDouble();

import 'dart:math';

class ImpermanentLoss {
  /// Sempre ≤ 0 (ou muito perto de 0 por erro de arredondamento): segurar
  /// os dois tokens separadamente nunca rende menos do que fornecer
  /// liquidez, pela fórmula clássica de IL.
  final double lossPct;

  /// Estimativa em USD do impacto acima, sobre o capital inicial — uma
  /// aproximação simples (`initialLiquidityUsd * lossPct/100`), não uma
  /// reconciliação exata token a token.
  final double lossUsd;

  const ImpermanentLoss({required this.lossPct, required this.lossUsd});
}

/// Estima o impermanent loss a partir da variação de preço desde a abertura
/// da posição, pela fórmula clássica (Pintail/Uniswap "Understanding
/// Returns"): `IL% = 2·√r / (1+r) − 1`, onde `r` é o rácio entre o preço
/// atual e o preço de entrada.
///
/// Como o preço de um par Uniswap v3 é `1.0001^tick`, o rácio é
/// `1.0001^(currentTick - entryTick)` — não é preciso saber os preços em
/// USD, nem os decimais dos tokens, para este cálculo (cancelam-se).
///
/// É uma aproximação para posições de range concentrado (a fórmula exata
/// assume liquidez de range completo, como no Uniswap v2); ainda assim dá
/// uma estimativa direcionalmente correta do custo de oportunidade de
/// fornecer liquidez em vez de só segurar os tokens.
ImpermanentLoss computeImpermanentLoss({
  required int entryTick,
  required int currentTick,
  required double initialLiquidityUsd,
}) {
  final tickDelta = (currentTick - entryTick).toDouble();
  final priceRatio = pow(1.0001, tickDelta).toDouble();

  if (priceRatio <= 0 || !priceRatio.isFinite) {
    return const ImpermanentLoss(lossPct: 0, lossUsd: 0);
  }

  final lossPct = (2 * sqrt(priceRatio) / (1 + priceRatio) - 1) * 100;
  // Arredondamentos de ponto flutuante podem dar um valor residual > 0
  // quando entryTick == currentTick; a fórmula nunca deveria dar ganho.
  final clampedLossPct = lossPct > 0 ? 0.0 : lossPct;

  return ImpermanentLoss(
    lossPct: clampedLossPct,
    lossUsd: initialLiquidityUsd * clampedLossPct / 100,
  );
}

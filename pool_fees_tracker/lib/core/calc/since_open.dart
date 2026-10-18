class SinceOpenPnl {
  final int daysOpen;
  final double feesEarnedUsd;
  final double feesEarnedPct;

  const SinceOpenPnl({
    required this.daysOpen,
    required this.feesEarnedUsd,
    required this.feesEarnedPct,
  });
}

/// Ganho acumulado desde a abertura da posição (mint do NFT), para
/// responder diretamente a "desde que abri isto, quanto já ganhei?".
SinceOpenPnl computeSinceOpen({
  required DateTime createdAt,
  required double feesTotalUsd,
  required double initialLiquidityUsd,
  required DateTime now,
}) {
  final daysOpen = now.difference(createdAt).inHours ~/ 24;
  final pct = initialLiquidityUsd > 0
      ? (feesTotalUsd / initialLiquidityUsd) * 100
      : 0.0;
  return SinceOpenPnl(
    daysOpen: daysOpen < 0 ? 0 : daysOpen,
    feesEarnedUsd: feesTotalUsd,
    feesEarnedPct: pct,
  );
}

import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import 'apr_calculator.dart';
import 'impermanent_loss.dart';
import 'projection_calculator.dart';

class DashboardMetrics {
  final double totalFeesUsd;
  final double fees24hUsd;

  /// Variação % entre os últimos 7 dias e os 7 dias anteriores a esses.
  /// `null` quando não há dados suficientes para comparar (posição nova).
  final double? pctChangeVsPrevWeek;

  final double avgAprPct;
  final double unclaimedUsd;

  /// Soma do impermanent loss (em USD) de todas as posições — ao contrário
  /// do ecrã de detalhe (que mostra IL em %), aqui soma-se em USD porque
  /// uma % média entre pools com capitais diferentes não diria nada de útil.
  final double ilUsd;

  /// Taxas geradas menos o IL acima — resposta direta a "no total, valeu
  /// mais a pena do que só ter guardado os tokens?".
  final double netVsHoldUsd;

  /// Soma da projeção de cada posição (mesmo cálculo do ecrã de detalhe,
  /// agregado) — para a resposta "quanto vou ganhar este mês/ano" não
  /// precisar de abrir pool a pool.
  final EarningsProjection projection;

  const DashboardMetrics({
    required this.totalFeesUsd,
    required this.fees24hUsd,
    required this.pctChangeVsPrevWeek,
    required this.avgAprPct,
    required this.unclaimedUsd,
    required this.ilUsd,
    required this.netVsHoldUsd,
    required this.projection,
  });
}

DashboardMetrics computeDashboardMetrics({
  required List<PoolPosition> positions,
  required Map<String, List<FeeSnapshot>> snapshotsByKey,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final last24hCutoff = effectiveNow.subtract(const Duration(hours: 24));
  final last7dCutoff = effectiveNow.subtract(const Duration(days: 7));
  final prev7dCutoff = effectiveNow.subtract(const Duration(days: 14));

  final startOfMonth = DateTime(effectiveNow.year, effectiveNow.month, 1);
  final startOfYear = DateTime(effectiveNow.year, 1, 1);

  double totalFeesUsd = 0;
  double fees24hUsd = 0;
  double feesLast7d = 0;
  double feesPrev7d = 0;
  double unclaimedUsd = 0;
  double aprSum = 0;
  var aprCount = 0;
  double totalAvgDailyFeeUsd = 0;
  double earnedThisMonth = 0;
  double earnedThisYear = 0;
  double ilUsd = 0;

  for (final position in positions) {
    totalFeesUsd += position.feesTotalUsd;
    unclaimedUsd += position.feesUnclaimedUsd;
    ilUsd += computeImpermanentLoss(
      entryTick: position.entryTick,
      currentTick: position.currentTick,
      initialLiquidityUsd: position.initialLiquidityUsd,
    ).lossUsd;

    final snapshots = snapshotsByKey[position.positionKey] ?? const [];
    var feesInLast7d = 0.0;
    for (final s in snapshots) {
      if (s.timestamp.isAfter(last24hCutoff)) fees24hUsd += s.feesUsdDelta;
      if (s.timestamp.isAfter(last7dCutoff)) {
        feesLast7d += s.feesUsdDelta;
        feesInLast7d += s.feesUsdDelta;
      } else if (s.timestamp.isAfter(prev7dCutoff)) {
        feesPrev7d += s.feesUsdDelta;
      }
      if (s.timestamp.isAfter(startOfMonth)) earnedThisMonth += s.feesUsdDelta;
      if (s.timestamp.isAfter(startOfYear)) earnedThisYear += s.feesUsdDelta;
    }
    totalAvgDailyFeeUsd += feesInLast7d / 7;

    if (position.liquidityUsd > 0) {
      aprSum += realizedAprPct(
        feesUsdEarnedInPeriod: feesInLast7d,
        liquidityUsd: position.liquidityUsd,
        periodDays: 7,
      );
      aprCount++;
    }
  }

  return DashboardMetrics(
    totalFeesUsd: totalFeesUsd,
    fees24hUsd: fees24hUsd,
    pctChangeVsPrevWeek: feesPrev7d > 0
        ? ((feesLast7d - feesPrev7d) / feesPrev7d) * 100
        : null,
    avgAprPct: aprCount > 0 ? aprSum / aprCount : 0,
    unclaimedUsd: unclaimedUsd,
    ilUsd: ilUsd,
    netVsHoldUsd: totalFeesUsd + ilUsd,
    projection: projectFromDailyRate(
      alreadyEarnedThisMonthUsd: earnedThisMonth,
      alreadyEarnedThisYearUsd: earnedThisYear,
      avgDailyFeeUsd: totalAvgDailyFeeUsd,
      now: effectiveNow,
    ),
  );
}

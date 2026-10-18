import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import 'apr_calculator.dart';

class DashboardMetrics {
  final double totalFeesUsd;
  final double fees24hUsd;

  /// Variação % entre os últimos 7 dias e os 7 dias anteriores a esses.
  /// `null` quando não há dados suficientes para comparar (posição nova).
  final double? pctChangeVsPrevWeek;

  final double avgAprPct;
  final double unclaimedUsd;

  const DashboardMetrics({
    required this.totalFeesUsd,
    required this.fees24hUsd,
    required this.pctChangeVsPrevWeek,
    required this.avgAprPct,
    required this.unclaimedUsd,
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

  double totalFeesUsd = 0;
  double fees24hUsd = 0;
  double feesLast7d = 0;
  double feesPrev7d = 0;
  double unclaimedUsd = 0;
  double aprSum = 0;
  var aprCount = 0;

  for (final position in positions) {
    totalFeesUsd += position.feesTotalUsd;
    unclaimedUsd += position.feesUnclaimedUsd;

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
    }

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
  );
}

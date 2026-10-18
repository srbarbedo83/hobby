import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import 'apr_calculator.dart';
import 'gas_break_even.dart';
import 'projection_calculator.dart';
import 'range_health.dart';
import 'since_open.dart';

/// Agrega todos os cálculos derivados de uma posição + o seu histórico de
/// fees, para os ecrãs não repetirem a mesma lógica de agregação.
class PoolMetrics {
  final RangeHealth rangeHealth;
  final SinceOpenPnl sinceOpen;
  final double avgDailyFeeUsd;
  final double realizedAprPct;
  final GasBreakEven gasBreakEven;
  final EarningsProjection projection;

  const PoolMetrics({
    required this.rangeHealth,
    required this.sinceOpen,
    required this.avgDailyFeeUsd,
    required this.realizedAprPct,
    required this.gasBreakEven,
    required this.projection,
  });
}

PoolMetrics computePoolMetrics({
  required PoolPosition position,
  required List<FeeSnapshot> snapshots,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();

  final last7dCutoff = effectiveNow.subtract(const Duration(days: 7));
  final sumLast7d = snapshots
      .where((s) => s.timestamp.isAfter(last7dCutoff))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);
  final avgDailyFeeUsd = sumLast7d / 7;

  final startOfMonth = DateTime(effectiveNow.year, effectiveNow.month, 1);
  final startOfYear = DateTime(effectiveNow.year, 1, 1);
  final earnedThisMonth = snapshots
      .where((s) => s.timestamp.isAfter(startOfMonth))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);
  final earnedThisYear = snapshots
      .where((s) => s.timestamp.isAfter(startOfYear))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);

  return PoolMetrics(
    rangeHealth: computeRangeHealth(
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
      currentTick: position.currentTick,
    ),
    sinceOpen: computeSinceOpen(
      createdAt: position.createdAt,
      feesTotalUsd: position.feesTotalUsd,
      initialLiquidityUsd: position.initialLiquidityUsd,
      now: effectiveNow,
    ),
    avgDailyFeeUsd: avgDailyFeeUsd,
    realizedAprPct: realizedAprPct(
      feesUsdEarnedInPeriod: sumLast7d,
      liquidityUsd: position.liquidityUsd,
      periodDays: 7,
    ),
    gasBreakEven: computeGasBreakEven(
      feesTotalUsd: position.feesTotalUsd,
      gasCostUsd: position.gasCostUsd,
      avgDailyFeeUsd: avgDailyFeeUsd,
    ),
    projection: projectFromDailyRate(
      alreadyEarnedThisMonthUsd: earnedThisMonth,
      alreadyEarnedThisYearUsd: earnedThisYear,
      avgDailyFeeUsd: avgDailyFeeUsd,
      now: effectiveNow,
    ),
  );
}

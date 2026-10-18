import '../../data/local/fee_snapshot.dart';
import 'bar_aggregator.dart';

class ComparisonPoint {
  final String label;
  final double valueA;
  final double valueB;

  const ComparisonPoint({
    required this.label,
    required this.valueA,
    required this.valueB,
  });
}

/// Junta o histórico de fees de duas posições na mesma grade de buckets de
/// tempo (preenchendo com 0 quando uma delas não tem snapshot nesse
/// bucket), para desenhar as duas séries no mesmo gráfico lado a lado.
List<ComparisonPoint> buildComparisonSeries({
  required List<FeeSnapshot> snapshotsA,
  required List<FeeSnapshot> snapshotsB,
  required ChartRange range,
  required ChartGroupBy groupBy,
  DateTime? now,
}) {
  final barsA = aggregateFeeSnapshots(
    snapshots: snapshotsA,
    range: range,
    groupBy: groupBy,
    now: now,
  );
  final barsB = aggregateFeeSnapshots(
    snapshots: snapshotsB,
    range: range,
    groupBy: groupBy,
    now: now,
  );
  final byBucketA = {for (final b in barsA) b.bucketStart: b};
  final byBucketB = {for (final b in barsB) b.bucketStart: b};
  final allBuckets = {...byBucketA.keys, ...byBucketB.keys}.toList()..sort();

  return [
    for (final bucket in allBuckets)
      ComparisonPoint(
        label: (byBucketA[bucket] ?? byBucketB[bucket])!.label,
        valueA: byBucketA[bucket]?.valueUsd ?? 0,
        valueB: byBucketB[bucket]?.valueUsd ?? 0,
      ),
  ];
}

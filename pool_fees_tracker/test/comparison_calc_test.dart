import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/bar_aggregator.dart';
import 'package:pool_fees_tracker/core/calc/comparison_calc.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';

FeeSnapshot _snap(String key, DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = key
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  test('preenche com 0 os buckets em que só uma posição tem snapshot', () {
    final now = DateTime(2026, 1, 10);
    final snapshotsA = [
      _snap('a', now.subtract(const Duration(hours: 2)), 10),
      _snap('a', now.subtract(const Duration(hours: 1)), 20),
    ];
    final snapshotsB = [_snap('b', now.subtract(const Duration(hours: 1)), 5)];

    final result = buildComparisonSeries(
      snapshotsA: snapshotsA,
      snapshotsB: snapshotsB,
      range: ChartRange.last24h,
      groupBy: ChartGroupBy.hour,
      now: now,
    );

    expect(result, hasLength(2));
    expect(result.first.valueA, 10);
    expect(result.first.valueB, 0);
    expect(result.last.valueA, 20);
    expect(result.last.valueB, 5);
  });

  test('listas vazias dão uma série vazia', () {
    final result = buildComparisonSeries(
      snapshotsA: const [],
      snapshotsB: const [],
      range: ChartRange.last7d,
      groupBy: ChartGroupBy.day,
    );
    expect(result, isEmpty);
  });
}

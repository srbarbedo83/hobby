import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/apr_history.dart';
import 'package:pool_fees_tracker/core/calc/bar_aggregator.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';

FeeSnapshot _snap(DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = 'p1'
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  final now = DateTime(2026, 2, 10, 12);

  test('uma barra por dia dá a APR anualizada daquele dia', () {
    final snapshots = [_snap(now.subtract(const Duration(hours: 6)), 10)];
    final history = computeAprHistory(
      snapshots: snapshots,
      liquidityUsd: 1000,
      range: ChartRange.last7d,
      groupBy: ChartGroupBy.day,
      now: now,
    );
    expect(history, hasLength(1));
    // 10/1000 * (365/1) * 100 = 365%
    expect(history.first.aprPct, closeTo(365, 0.01));
  });

  test('sem fees no período dá uma lista vazia de barras', () {
    final history = computeAprHistory(
      snapshots: const [],
      liquidityUsd: 1000,
      range: ChartRange.last7d,
      groupBy: ChartGroupBy.day,
      now: now,
    );
    expect(history, isEmpty);
  });

  test('liquidez 0 dá APR 0 em vez de Infinity/NaN', () {
    final snapshots = [_snap(now.subtract(const Duration(hours: 6)), 10)];
    final history = computeAprHistory(
      snapshots: snapshots,
      liquidityUsd: 0,
      range: ChartRange.last7d,
      groupBy: ChartGroupBy.day,
      now: now,
    );
    expect(history.first.aprPct, 0);
  });

  test('agrupamento por hora usa uma fração de dia, não arredonda para 1 dia inteiro', () {
    final snapshots = [_snap(now.subtract(const Duration(minutes: 10)), 1)];
    final history = computeAprHistory(
      snapshots: snapshots,
      liquidityUsd: 1000,
      range: ChartRange.last24h,
      groupBy: ChartGroupBy.hour,
      now: now,
    );
    // 1/1000 * (365/(1/24)) * 100 = 876%
    expect(history.first.aprPct, closeTo(876, 1));
  });
}

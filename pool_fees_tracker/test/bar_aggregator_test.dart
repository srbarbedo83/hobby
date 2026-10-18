import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/bar_aggregator.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';

FeeSnapshot _snap(DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = 'ethereum:1'
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  group('aggregateFeeSnapshots', () {
    final now = DateTime(2026, 1, 10, 12);

    test('agrupa por dia dentro do intervalo de 7 dias', () {
      final snapshots = [
        _snap(now.subtract(const Duration(days: 1, hours: 1)), 10),
        _snap(now.subtract(const Duration(days: 1, hours: 2)), 5),
        _snap(now.subtract(const Duration(days: 2)), 7),
      ];
      final bars = aggregateFeeSnapshots(
        snapshots: snapshots,
        range: ChartRange.last7d,
        groupBy: ChartGroupBy.day,
        now: now,
      );
      expect(bars.length, 2);
      expect(bars.last.valueUsd, closeTo(15, 0.001));
    });

    test('ignora snapshots fora do intervalo pedido', () {
      final snapshots = [
        _snap(now.subtract(const Duration(days: 40)), 100),
        _snap(now.subtract(const Duration(hours: 2)), 3),
      ];
      final bars = aggregateFeeSnapshots(
        snapshots: snapshots,
        range: ChartRange.last24h,
        groupBy: ChartGroupBy.hour,
        now: now,
      );
      expect(bars.length, 1);
      expect(bars.first.valueUsd, 3);
    });

    test('ChartRange.allTime não filtra nada, mesmo histórico antigo', () {
      final snapshots = [_snap(now.subtract(const Duration(days: 400)), 42)];
      final bars = aggregateFeeSnapshots(
        snapshots: snapshots,
        range: ChartRange.allTime,
        groupBy: ChartGroupBy.month,
        now: now,
      );
      expect(bars.length, 1);
      expect(bars.first.valueUsd, 42);
    });

    test('barras saem ordenadas cronologicamente', () {
      final snapshots = [
        _snap(now.subtract(const Duration(days: 1)), 1),
        _snap(now.subtract(const Duration(days: 5)), 2),
        _snap(now.subtract(const Duration(days: 3)), 3),
      ];
      final bars = aggregateFeeSnapshots(
        snapshots: snapshots,
        range: ChartRange.last7d,
        groupBy: ChartGroupBy.day,
        now: now,
      );
      for (var i = 1; i < bars.length; i++) {
        expect(bars[i].bucketStart.isAfter(bars[i - 1].bucketStart), isTrue);
      }
    });
  });

  group('ChartRange.allowedGroupBys', () {
    test('24H só permite agrupar por hora', () {
      expect(ChartRange.last24h.allowedGroupBys, [ChartGroupBy.hour]);
    });

    test('ALL só permite agrupar por mês', () {
      expect(ChartRange.allTime.allowedGroupBys, [ChartGroupBy.month]);
    });
  });
}

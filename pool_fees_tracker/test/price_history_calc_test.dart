import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/bar_aggregator.dart';
import 'package:pool_fees_tracker/core/calc/price_history_calc.dart';
import 'package:pool_fees_tracker/data/local/price_point.dart';

PricePoint _point(DateTime t, int tick) => PricePoint()
  ..positionKey = 'p1'
  ..timestamp = t
  ..tick = tick;

void main() {
  group('aggregatePricePoints', () {
    test('agrega a média do tick por bucket', () {
      final now = DateTime(2026, 1, 10);
      final points = [
        _point(now.subtract(const Duration(hours: 3)), 100),
        _point(now.subtract(const Duration(hours: 2)), 200),
        _point(now.subtract(const Duration(hours: 1)), 300),
      ];
      final result = aggregatePricePoints(
        points: points,
        range: ChartRange.last24h,
        groupBy: ChartGroupBy.hour,
        now: now,
      );
      expect(result, hasLength(3));
      expect(result.map((p) => p.avgTick), [100.0, 200.0, 300.0]);
    });

    test('ignora pontos fora do lookback do range escolhido', () {
      final now = DateTime(2026, 1, 10);
      final points = [
        _point(now.subtract(const Duration(days: 10)), 1),
        _point(now.subtract(const Duration(hours: 1)), 999),
      ];
      final result = aggregatePricePoints(
        points: points,
        range: ChartRange.last24h,
        groupBy: ChartGroupBy.hour,
        now: now,
      );
      expect(result, hasLength(1));
      expect(result.single.avgTick, 999.0);
    });
  });

  group('currentOutOfRangeDuration', () {
    test('null quando o ponto mais recente está dentro do range', () {
      final now = DateTime(2026, 1, 10);
      final points = [_point(now.subtract(const Duration(hours: 1)), 5)];
      expect(
        currentOutOfRangeDuration(
          points: points,
          tickLower: 0,
          tickUpper: 10,
          now: now,
        ),
        isNull,
      );
    });

    test('mede desde o início da sequência contínua fora do range', () {
      final now = DateTime(2026, 1, 10, 12);
      final points = [
        _point(now.subtract(const Duration(hours: 5)), 5), // dentro
        _point(now.subtract(const Duration(hours: 4)), 50), // sai
        _point(now.subtract(const Duration(hours: 3)), 60),
        _point(now.subtract(const Duration(hours: 2)), 70),
        _point(now.subtract(const Duration(hours: 1)), 80), // ainda fora
      ];
      final duration = currentOutOfRangeDuration(
        points: points,
        tickLower: 0,
        tickUpper: 10,
        now: now,
      );
      expect(duration, const Duration(hours: 4));
    });
  });

  group('inRangeStreakDays', () {
    test('streak atual e mais longo com histórico só dentro do range', () {
      final now = DateTime(2026, 1, 10);
      final points = [
        for (var d = 3; d >= 0; d--) _point(now.subtract(Duration(days: d)), 5),
      ];
      final result = inRangeStreakDays(
        points: points,
        tickLower: 0,
        tickUpper: 10,
        now: now,
      );
      expect(result.current, 4);
      expect(result.longest, 4);
    });

    test('um dia fora do range quebra o streak atual mas conta no maior', () {
      final now = DateTime(2026, 1, 10);
      final points = [
        _point(now.subtract(const Duration(days: 5)), 5), // in
        _point(now.subtract(const Duration(days: 4)), 5), // in
        _point(now.subtract(const Duration(days: 3)), 50), // out
        _point(now.subtract(const Duration(days: 2)), 5), // in
        _point(now.subtract(const Duration(days: 1)), 5), // in
        _point(now, 5), // in
      ];
      final result = inRangeStreakDays(
        points: points,
        tickLower: 0,
        tickUpper: 10,
        now: now,
      );
      expect(result.current, 3);
      expect(result.longest, 3);
    });

    test('lista vazia dá streaks a zero', () {
      final result = inRangeStreakDays(
        points: const [],
        tickLower: 0,
        tickUpper: 10,
      );
      expect(result.current, 0);
      expect(result.longest, 0);
    });
  });
}

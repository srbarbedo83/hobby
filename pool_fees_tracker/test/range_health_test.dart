import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/range_health.dart';

void main() {
  group('computeRangeHealth', () {
    test('tick no centro do range está "inRange"', () {
      final health = computeRangeHealth(
        tickLower: -100,
        tickUpper: 100,
        currentTick: 0,
      );
      expect(health.status, RangeStatus.inRange);
      expect(health.positionFraction, closeTo(0.5, 0.001));
    });

    test('tick muito perto da margem superior está "nearEdge"', () {
      final health = computeRangeHealth(
        tickLower: 0,
        tickUpper: 100,
        currentTick: 95,
      );
      expect(health.status, RangeStatus.nearEdge);
    });

    test('tick acima do tickUpper está "outOfRange"', () {
      final health = computeRangeHealth(
        tickLower: -50,
        tickUpper: 50,
        currentTick: 80,
      );
      expect(health.status, RangeStatus.outOfRange);
      expect(health.positionFraction, greaterThan(1));
    });

    test('tick abaixo do tickLower está "outOfRange"', () {
      final health = computeRangeHealth(
        tickLower: -50,
        tickUpper: 50,
        currentTick: -80,
      );
      expect(health.status, RangeStatus.outOfRange);
      expect(health.positionFraction, lessThan(0));
    });

    test('range de largura zero não divide por zero', () {
      final health = computeRangeHealth(
        tickLower: 10,
        tickUpper: 10,
        currentTick: 10,
      );
      expect(health.status, RangeStatus.inRange);
    });
  });
}

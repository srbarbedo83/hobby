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

  group('rangeDotPositionFraction', () {
    test('dentro do range é 1:1 (identidade)', () {
      expect(rangeDotPositionFraction(0), 0);
      expect(rangeDotPositionFraction(0.5), 0.5);
      expect(rangeDotPositionFraction(1), 1);
    });

    test('fora do range fica dentro da margem reservada', () {
      final farBelow = rangeDotPositionFraction(-50, overflowFraction: 0.25);
      final farAbove = rangeDotPositionFraction(51, overflowFraction: 0.25);
      expect(farBelow, greaterThan(-0.25));
      expect(farAbove, lessThan(1.25));
    });

    test('quanto mais fora, mais perto do limite da margem', () {
      final slightlyBelow = rangeDotPositionFraction(
        -0.1,
        overflowFraction: 0.25,
      );
      final farBelow = rangeDotPositionFraction(-10, overflowFraction: 0.25);
      expect(farBelow.abs(), greaterThan(slightlyBelow.abs()));
      expect(farBelow, greaterThan(-0.25));
    });

    test('simétrico entre sair por baixo e sair por cima', () {
      final below = rangeDotPositionFraction(-2, overflowFraction: 0.25);
      final above = rangeDotPositionFraction(3, overflowFraction: 0.25);
      // -2 está 2 abaixo de 0; 3 está 2 acima de 1 — mesma distância.
      expect(below.abs(), closeTo((above - 1).abs(), 1e-9));
    });
  });
}

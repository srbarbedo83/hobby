import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/projection_calculator.dart';

void main() {
  group('projectFromDailyRate', () {
    test('projeta o resto do mês e do ano à taxa diária atual', () {
      final now = DateTime(2026, 3, 20);
      final projection = projectFromDailyRate(
        alreadyEarnedThisMonthUsd: 100,
        alreadyEarnedThisYearUsd: 400,
        avgDailyFeeUsd: 10,
        now: now,
      );

      final daysRemainingInMonth =
          DateTime(2026, 4, 1).difference(now).inHours / 24;
      expect(
        projection.projectedEndOfMonthUsd,
        closeTo(100 + 10 * daysRemainingInMonth, 0.5),
      );

      final daysRemainingInYear =
          DateTime(2027, 1, 1).difference(now).inHours / 24;
      expect(
        projection.projectedEndOfYearUsd,
        closeTo(400 + 10 * daysRemainingInYear, 0.5),
      );
    });

    test('dezembro: o próximo mês começa a 1 de janeiro do ano seguinte', () {
      final now = DateTime(2026, 12, 30);
      final projection = projectFromDailyRate(
        alreadyEarnedThisMonthUsd: 50,
        alreadyEarnedThisYearUsd: 500,
        avgDailyFeeUsd: 2,
        now: now,
      );
      // 2 dias restantes (30->31->1 jan), não deve lançar nem dar negativo.
      expect(projection.projectedEndOfMonthUsd, greaterThanOrEqualTo(50));
    });

    test('taxa diária zero não altera a projeção', () {
      final now = DateTime(2026, 6, 15);
      final projection = projectFromDailyRate(
        alreadyEarnedThisMonthUsd: 30,
        alreadyEarnedThisYearUsd: 300,
        avgDailyFeeUsd: 0,
        now: now,
      );
      expect(projection.projectedEndOfMonthUsd, 30);
      expect(projection.projectedEndOfYearUsd, 300);
    });
  });
}

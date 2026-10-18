import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/gas_break_even.dart';

void main() {
  group('computeGasBreakEven', () {
    test('ainda não atingido: calcula quanto falta e estimativa de dias', () {
      final result = computeGasBreakEven(
        feesTotalUsd: 20,
        gasCostUsd: 50,
        avgDailyFeeUsd: 5,
      );
      expect(result.reached, isFalse);
      expect(result.remainingUsd, 30);
      expect(result.estimatedDaysRemaining, 6);
    });

    test('atingido quando fees >= gas', () {
      final result = computeGasBreakEven(
        feesTotalUsd: 60,
        gasCostUsd: 50,
        avgDailyFeeUsd: 5,
      );
      expect(result.reached, isTrue);
      expect(result.remainingUsd, 0);
      expect(result.estimatedDaysRemaining, isNull);
    });

    test('exatamente no limite conta como atingido', () {
      final result = computeGasBreakEven(
        feesTotalUsd: 50,
        gasCostUsd: 50,
        avgDailyFeeUsd: 5,
      );
      expect(result.reached, isTrue);
    });

    test('sem ritmo diário positivo não arrisca divisão por zero', () {
      final result = computeGasBreakEven(
        feesTotalUsd: 0,
        gasCostUsd: 50,
        avgDailyFeeUsd: 0,
      );
      expect(result.reached, isFalse);
      expect(result.estimatedDaysRemaining, isNull);
    });
  });
}

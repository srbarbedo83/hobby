import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/since_open.dart';

void main() {
  group('computeSinceOpen', () {
    test('calcula dias abertos e % de retorno sobre o capital inicial', () {
      final result = computeSinceOpen(
        createdAt: DateTime(2026, 1, 1),
        feesTotalUsd: 150,
        initialLiquidityUsd: 3000,
        now: DateTime(2026, 1, 31),
      );
      expect(result.daysOpen, 30);
      expect(result.feesEarnedUsd, 150);
      expect(result.feesEarnedPct, closeTo(5.0, 0.001));
    });

    test('sem capital inicial conhecido devolve 0% em vez de Infinity', () {
      final result = computeSinceOpen(
        createdAt: DateTime(2026, 1, 1),
        feesTotalUsd: 150,
        initialLiquidityUsd: 0,
        now: DateTime(2026, 1, 31),
      );
      expect(result.feesEarnedPct, 0);
    });

    test('nunca devolve dias negativos mesmo com relógios ligeiramente desalinhados', () {
      final result = computeSinceOpen(
        createdAt: DateTime(2026, 1, 10),
        feesTotalUsd: 1,
        initialLiquidityUsd: 100,
        now: DateTime(2026, 1, 9, 23, 59),
      );
      expect(result.daysOpen, 0);
    });
  });
}

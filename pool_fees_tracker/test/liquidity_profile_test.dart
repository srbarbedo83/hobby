import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/liquidity_profile.dart';

void main() {
  group('computeRangeConcentrationPct', () {
    test('lista vazia dá 0%', () {
      expect(
        computeRangeConcentrationPct(
          profile: const [],
          tickLower: -10,
          tickUpper: 10,
        ),
        0,
      );
    });

    test('toda a liquidez dentro do range dá 100%', () {
      final profile = [
        const TickLiquidity(tick: -5, liquidityGross: 100),
        const TickLiquidity(tick: 5, liquidityGross: 200),
      ];
      expect(
        computeRangeConcentrationPct(
          profile: profile,
          tickLower: -10,
          tickUpper: 10,
        ),
        100,
      );
    });

    test('calcula a fração correta quando só parte está dentro', () {
      final profile = [
        const TickLiquidity(tick: -5, liquidityGross: 300), // dentro
        const TickLiquidity(tick: 50, liquidityGross: 100), // fora
      ];
      final pct = computeRangeConcentrationPct(
        profile: profile,
        tickLower: -10,
        tickUpper: 10,
      );
      expect(pct, closeTo(75.0, 0.001));
    });
  });
}

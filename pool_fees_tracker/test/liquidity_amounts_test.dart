import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/liquidity_amounts.dart';

void main() {
  group('getAmountsForLiquidity', () {
    test('tick abaixo do range: tudo em token0, nada em token1', () {
      final result = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: -100,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(result.amount0, greaterThan(0));
      expect(result.amount1, 0);
    });

    test('tick acima do range: tudo em token1, nada em token0', () {
      final result = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: 2000,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(result.amount0, 0);
      expect(result.amount1, greaterThan(0));
    });

    test('tick dentro do range: ambos os tokens positivos', () {
      final result = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: 500,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(result.amount0, greaterThan(0));
      expect(result.amount1, greaterThan(0));
    });

    test('exatamente no tickLower: equivalente a estar abaixo do range', () {
      final result = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: 0,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(result.amount1, 0);
    });

    test('liquidez zero dá sempre amounts a zero', () {
      final result = getAmountsForLiquidity(
        liquidity: 0,
        tick: 500,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(result.amount0, 0);
      expect(result.amount1, 0);
    });

    test('range inválido (tickUpper <= tickLower) não rebenta', () {
      final result = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: 500,
        tickLower: 1000,
        tickUpper: 1000,
      );
      expect(result.amount0, 0);
      expect(result.amount1, 0);
    });

    test('cresce com a liquidez (mesmo range/tick)', () {
      final small = getAmountsForLiquidity(
        liquidity: 1e12,
        tick: 500,
        tickLower: 0,
        tickUpper: 1000,
      );
      final big = getAmountsForLiquidity(
        liquidity: 2e12,
        tick: 500,
        tickLower: 0,
        tickUpper: 1000,
      );
      expect(big.amount0, greaterThan(small.amount0));
      expect(big.amount1, greaterThan(small.amount1));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/univ3_fee_math.dart';

final BigInt _q128 = BigInt.one << 128;

void main() {
  group('wrap256', () {
    test('não altera valores já dentro de 0..2^256-1', () {
      expect(wrap256(BigInt.from(42)), BigInt.from(42));
    });

    test(
      'valores negativos dão a volta como unsigned de 256 bits (como a EVM)',
      () {
        final expected = (BigInt.one << 256) - BigInt.from(5);
        expect(wrap256(BigInt.from(-5)), expected);
      },
    );
  });

  group('feeGrowthInsideX128', () {
    test('tick atual dentro do range: usa feeGrowthOutside diretamente', () {
      final inside = feeGrowthInsideX128(
        feeGrowthGlobalX128: BigInt.from(5) * _q128,
        feeGrowthOutsideLowerX128: BigInt.from(1) * _q128,
        feeGrowthOutsideUpperX128: BigInt.from(1) * _q128,
        currentTick: 0,
        tickLower: -100,
        tickUpper: 100,
      );
      expect(inside, BigInt.from(3) * _q128);
    });

    test('tick atual abaixo do tickLower: inverte o lado "below"', () {
      final inside = feeGrowthInsideX128(
        feeGrowthGlobalX128: BigInt.from(10) * _q128,
        feeGrowthOutsideLowerX128: BigInt.from(3) * _q128,
        feeGrowthOutsideUpperX128: BigInt.from(2) * _q128,
        currentTick: 0,
        tickLower: 100,
        tickUpper: 200,
      );
      // below = global - outsideLower = 7; above = outsideUpper = 2; inside = 10-7-2=1
      expect(inside, BigInt.from(1) * _q128);
    });

    test('tick atual acima do tickUpper: inverte o lado "above"', () {
      final inside = feeGrowthInsideX128(
        feeGrowthGlobalX128: BigInt.from(10) * _q128,
        feeGrowthOutsideLowerX128: BigInt.from(2) * _q128,
        feeGrowthOutsideUpperX128: BigInt.from(3) * _q128,
        currentTick: 300,
        tickLower: 100,
        tickUpper: 200,
      );
      // below = outsideLower = 2; above = global - outsideUpper = 7; inside = 10-2-7=1
      expect(inside, BigInt.from(1) * _q128);
    });
  });

  group('tokensOwed', () {
    test(
      'multiplica o delta de feeGrowth pela liquidez e divide por 2^128',
      () {
        final owed = tokensOwed(
          feeGrowthInsideX128: BigInt.from(3) * _q128,
          feeGrowthInsideLastX128: BigInt.from(2) * _q128,
          liquidity: BigInt.from(1000),
        );
        expect(owed, BigInt.from(1000));
      },
    );

    test('sem acréscimo de feeGrowth não há fees novas em dívida', () {
      final owed = tokensOwed(
        feeGrowthInsideX128: BigInt.from(2) * _q128,
        feeGrowthInsideLastX128: BigInt.from(2) * _q128,
        liquidity: BigInt.from(999999),
      );
      expect(owed, BigInt.zero);
    });
  });

  group('computeUnclaimedTokens', () {
    test('calcula owed0 e owed1 independentemente', () {
      final result = computeUnclaimedTokens(
        feeGrowthGlobal0X128: BigInt.from(5) * _q128,
        feeGrowthGlobal1X128: BigInt.from(8) * _q128,
        feeGrowthOutsideLower0X128: BigInt.from(1) * _q128,
        feeGrowthOutsideLower1X128: BigInt.from(1) * _q128,
        feeGrowthOutsideUpper0X128: BigInt.from(1) * _q128,
        feeGrowthOutsideUpper1X128: BigInt.from(1) * _q128,
        feeGrowthInsideLast0X128: BigInt.from(2) * _q128,
        feeGrowthInsideLast1X128: BigInt.from(2) * _q128,
        liquidity: BigInt.from(500),
        currentTick: 0,
        tickLower: -100,
        tickUpper: 100,
      );
      // inside0 = 5-1-1=3 -> delta vs last(2) = 1 -> owed0 = 500
      expect(result.owed0, BigInt.from(500));
      // inside1 = 8-1-1=6 -> delta vs last(2) = 4 -> owed1 = 2000
      expect(result.owed1, BigInt.from(2000));
    });
  });

  group('tokenAmountToDouble', () {
    test('divide corretamente por 10^decimals', () {
      expect(
        tokenAmountToDouble(BigInt.from(123456), 2),
        closeTo(1234.56, 0.0001),
      );
    });

    test('18 decimais (padrão ERC-20) converte wei para unidades inteiras', () {
      expect(
        tokenAmountToDouble(BigInt.parse('1000000000000000000'), 18),
        closeTo(1.0, 1e-9),
      );
    });

    test('0 decimais devolve o valor tal como está', () {
      expect(tokenAmountToDouble(BigInt.from(42), 0), 42.0);
    });
  });

  group('priceAtTick', () {
    test('tick 0 com os mesmos decimais nos dois tokens dá preço 1.0', () {
      expect(
        priceAtTick(tick: 0, token0Decimals: 18, token1Decimals: 18),
        closeTo(1.0, 1e-9),
      );
    });

    test('ajusta pela diferença de decimais entre token0 e token1', () {
      // token0 com 18 decimais, token1 com 6 (ex.: ETH/USDC): o mesmo tick
      // vale 10^12 vezes mais em unidades humanas.
      final price18v18 = priceAtTick(
        tick: 1000,
        token0Decimals: 18,
        token1Decimals: 18,
      );
      final price18v6 = priceAtTick(
        tick: 1000,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      expect(price18v6 / price18v18, closeTo(1e12, 1));
    });

    test('é monótono crescente em tick (preço sobe com o tick)', () {
      final lower = priceAtTick(
        tick: -201180,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      final upper = priceAtTick(
        tick: -200980,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      expect(upper, greaterThan(lower));
    });

    test('ETH/USDC perto de -201080 dá um preço plausível (~1800-1900)', () {
      final price = priceAtTick(
        tick: -201060,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      expect(price, greaterThan(1800));
      expect(price, lessThan(1900));
    });
  });

  group('tickAtPrice', () {
    test('é o inverso de priceAtTick (ida e volta dá o tick original)', () {
      const originalTick = -201060;
      final price = priceAtTick(
        tick: originalTick,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      final roundTrippedTick = tickAtPrice(
        price: price,
        token0Decimals: 18,
        token1Decimals: 6,
      );
      expect(roundTrippedTick, closeTo(originalTick, 0.01));
    });

    test('preço 1.0 com os mesmos decimais dá tick 0', () {
      expect(
        tickAtPrice(price: 1.0, token0Decimals: 18, token1Decimals: 18),
        closeTo(0, 1e-6),
      );
    });
  });
}

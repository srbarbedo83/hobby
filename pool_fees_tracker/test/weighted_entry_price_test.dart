import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/univ3_fee_math.dart';
import 'package:pool_fees_tracker/core/calc/weighted_entry_price.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required int entryTick,
  required double initialLiquidityUsd,
  int token0Decimals = 18,
  int token1Decimals = 18,
}) {
  return PoolPosition()
    ..positionKey = 'k$entryTick-$initialLiquidityUsd'
    ..chain = Chain.ethereum
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = 'ETH'
    ..token1Symbol = 'USDC'
    ..token0Decimals = token0Decimals
    ..token1Decimals = token1Decimals
    ..feeTierBps = 500
    ..createdAt = DateTime(2025, 1, 1)
    ..tickLower = -1000
    ..tickUpper = 1000
    ..currentTick = 0
    ..entryTick = entryTick
    ..liquidityUsd = initialLiquidityUsd
    ..initialLiquidityUsd = initialLiquidityUsd
    ..feesClaimedUsd = 0
    ..feesUnclaimedUsd = 0
    ..gasCostUsd = 0
    ..isClosed = false;
}

void main() {
  group('weightedAverageEntryPrice', () {
    test('lista vazia dá null', () {
      expect(weightedAverageEntryPrice(const []), isNull);
    });

    test('capital inicial todo a 0 dá null (nada para ponderar)', () {
      final positions = [
        _position(entryTick: 0, initialLiquidityUsd: 0),
        _position(entryTick: 100, initialLiquidityUsd: 0),
      ];
      expect(weightedAverageEntryPrice(positions), isNull);
    });

    test('uma só posição dá o preço de entrada dessa posição', () {
      final positions = [_position(entryTick: 100, initialLiquidityUsd: 500)];
      final expected = priceAtTick(
        tick: 100,
        token0Decimals: 18,
        token1Decimals: 18,
      );
      expect(weightedAverageEntryPrice(positions), expected);
    });

    test('pesa pelo capital inicial, não pela média simples dos ticks', () {
      // Posição grande em tick 0, posição pequena em tick 200 — o tick
      // ponderado deve ficar muito mais próximo de 0 do que de 100 (que
      // seria a média simples).
      final positions = [
        _position(entryTick: 0, initialLiquidityUsd: 9000),
        _position(entryTick: 200, initialLiquidityUsd: 1000),
      ];
      final weightedPrice = weightedAverageEntryPrice(positions)!;
      final simpleAvgPrice = priceAtTick(
        tick: 100,
        token0Decimals: 18,
        token1Decimals: 18,
      );
      final priceAtZero = priceAtTick(
        tick: 0,
        token0Decimals: 18,
        token1Decimals: 18,
      );
      expect(
        (weightedPrice - priceAtZero).abs(),
        lessThan((weightedPrice - simpleAvgPrice).abs()),
      );
    });
  });
}

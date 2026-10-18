import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/out_of_range_estimate.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';
import 'package:pool_fees_tracker/data/local/price_point.dart';

PricePoint _point(DateTime t, int tick) => PricePoint()
  ..positionKey = 'p1'
  ..timestamp = t
  ..tick = tick;

PoolPosition _position({
  int tickLower = -100,
  int tickUpper = 100,
  int currentTick = 0,
}) {
  return PoolPosition()
    ..positionKey = 'p1'
    ..chain = Chain.ethereum
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = 'ETH'
    ..token1Symbol = 'USDC'
    ..feeTierBps = 500
    ..createdAt = DateTime(2026, 1, 1)
    ..tickLower = tickLower
    ..tickUpper = tickUpper
    ..currentTick = currentTick
    ..entryTick = 0
    ..liquidityUsd = 1000
    ..initialLiquidityUsd = 1000
    ..feesClaimedUsd = 0
    ..feesUnclaimedUsd = 0
    ..gasCostUsd = 0;
}

void main() {
  group('estimateMissedFees', () {
    test('null quando a posição está dentro do range', () {
      final now = DateTime(2026, 1, 10);
      final points = [_point(now.subtract(const Duration(hours: 1)), 5)];
      final result = estimateMissedFees(
        pricePoints: points,
        tickLower: 0,
        tickUpper: 10,
        feesTotalUsd: 100,
        createdAt: DateTime(2026, 1, 1),
        now: now,
      );
      expect(result, isNull);
    });

    test('estima com a taxa diária histórica dos dias em range', () {
      final createdAt = DateTime(2026, 1, 1);
      final now = DateTime(2026, 1, 9); // 8 dias de vida
      final points = [
        _point(createdAt.add(const Duration(hours: 1)), 5), // em range
        _point(now.subtract(const Duration(days: 2, hours: 1)), 5), // em range
        _point(now.subtract(const Duration(days: 2)), 50), // sai do range
        _point(now.subtract(const Duration(hours: 1)), 50), // ainda fora
      ];
      // 8 dias totais - 2 fora = 6 dias em range; $60 ao longo de 6 dias
      // em range = $10/dia; 2 dias fora = $20 perdidos.
      final result = estimateMissedFees(
        pricePoints: points,
        tickLower: 0,
        tickUpper: 10,
        feesTotalUsd: 60,
        createdAt: createdAt,
        now: now,
      );
      expect(result, isNotNull);
      expect(result!.duration, const Duration(days: 2));
      expect(result.missedFeesUsd, closeTo(20, 0.01));
    });
  });

  group('suggestRebalance', () {
    test('null quando a duração fora do range não atinge o threshold', () {
      final estimate = OutOfRangeEstimate(
        duration: const Duration(hours: 2),
        missedFeesUsd: 5,
      );
      expect(
        suggestRebalance(position: _position(), estimate: estimate),
        isNull,
      );
    });

    test('sugere um range com a mesma largura, recentrado no tick atual', () {
      final estimate = OutOfRangeEstimate(
        duration: const Duration(hours: 30),
        missedFeesUsd: 12,
      );
      final suggestion = suggestRebalance(
        position: _position(tickLower: -100, tickUpper: 100, currentTick: 150),
        estimate: estimate,
      );
      expect(suggestion, isNotNull);
      expect(suggestion!.newTickLower, 50);
      expect(suggestion.newTickUpper, 250);
    });
  });
}

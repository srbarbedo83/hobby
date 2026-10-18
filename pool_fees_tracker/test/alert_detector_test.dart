import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/alert_detector.dart';
import 'package:pool_fees_tracker/core/calc/range_health.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  int tickLower = -100,
  int tickUpper = 100,
  int currentTick = 0,
  double feesClaimedUsd = 0,
  double feesUnclaimedUsd = 0,
  bool isClosed = false,
}) {
  return PoolPosition()
    ..positionKey = key
    ..chain = Chain.ethereum
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = 'ETH'
    ..token1Symbol = 'USDC'
    ..feeTierBps = 500
    ..createdAt = DateTime(2025, 1, 1)
    ..tickLower = tickLower
    ..tickUpper = tickUpper
    ..currentTick = currentTick
    ..entryTick = 0
    ..liquidityUsd = 1000
    ..initialLiquidityUsd = 1000
    ..feesClaimedUsd = feesClaimedUsd
    ..feesUnclaimedUsd = feesUnclaimedUsd
    ..gasCostUsd = 0
    ..isClosed = isClosed;
}

void main() {
  group('detectRangeTransitions', () {
    test('alerta quando uma posição acabou de sair do range', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      final alerts = detectRangeTransitions(
        positions: positions,
        previousStatusByKey: {'a': RangeStatus.inRange},
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.kind, AlertKind.outOfRange);
    });

    test('não alerta de novo se já estava fora de range antes', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      final alerts = detectRangeTransitions(
        positions: positions,
        previousStatusByKey: {'a': RangeStatus.outOfRange},
      );
      expect(alerts, isEmpty);
    });

    test('não alerta para posições dentro do range', () {
      final positions = [_position(key: 'a', currentTick: 0)];
      final alerts = detectRangeTransitions(
        positions: positions,
        previousStatusByKey: {'a': RangeStatus.inRange},
      );
      expect(alerts, isEmpty);
    });

    test('ignora posições fechadas', () {
      final positions = [_position(key: 'a', currentTick: 150, isClosed: true)];
      final alerts = detectRangeTransitions(
        positions: positions,
        previousStatusByKey: {'a': RangeStatus.inRange},
      );
      expect(alerts, isEmpty);
    });

    test('posição nova (sem estado anterior) que já está fora alerta', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      final alerts = detectRangeTransitions(
        positions: positions,
        previousStatusByKey: {},
      );
      expect(alerts, hasLength(1));
    });
  });

  group('detectFeeMilestones', () {
    test('alerta ao passar o primeiro threshold', () {
      final positions = [_position(key: 'a', feesClaimedUsd: 55)];
      final alerts = detectFeeMilestones(
        positions: positions,
        lastNotifiedFeesByKey: {},
        thresholdUsd: 50,
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.newNotifiedFeesTotal, 55);
    });

    test('não alerta de novo antes de passar o próximo múltiplo', () {
      final positions = [_position(key: 'a', feesClaimedUsd: 60)];
      final alerts = detectFeeMilestones(
        positions: positions,
        lastNotifiedFeesByKey: {'a': 55},
        thresholdUsd: 50,
      );
      expect(alerts, isEmpty);
    });

    test('alerta de novo depois de passar o threshold seguinte', () {
      final positions = [_position(key: 'a', feesClaimedUsd: 110)];
      final alerts = detectFeeMilestones(
        positions: positions,
        lastNotifiedFeesByKey: {'a': 55},
        thresholdUsd: 50,
      );
      expect(alerts, hasLength(1));
    });

    test('threshold 0 ou negativo nunca alerta', () {
      final positions = [_position(key: 'a', feesClaimedUsd: 1000)];
      expect(
        detectFeeMilestones(
          positions: positions,
          lastNotifiedFeesByKey: {},
          thresholdUsd: 0,
        ),
        isEmpty,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/alert_detector.dart';
import 'package:pool_fees_tracker/core/calc/range_health.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';
import 'package:pool_fees_tracker/data/local/price_alert_rule.dart';

PriceAlertRule _rule({
  required String positionKey,
  required int thresholdTick,
  required PriceAlertDirection direction,
  bool enabled = true,
  bool lastTriggered = false,
}) {
  return PriceAlertRule()
    ..positionKey = positionKey
    ..thresholdTick = thresholdTick
    ..direction = direction
    ..enabled = enabled
    ..lastTriggered = lastTriggered;
}

FeeSnapshot _snap(String key, DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = key
    ..timestamp = t
    ..feesUsdDelta = delta;
}

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

  group('isFeeSlowdown', () {
    final now = DateTime(2026, 2, 1, 12);

    test('true quando as últimas 24h ganharam bem menos que a média de 7d', () {
      final snapshots = [
        for (var d = 1; d <= 7; d++)
          _snap(
            'a',
            now.subtract(Duration(days: d)),
            14,
          ), // $14/dia, 7 dias = $98 -> média $14/dia
        _snap(
          'a',
          now.subtract(const Duration(hours: 12)),
          1,
        ), // só $1 nas últimas 24h
      ];
      expect(isFeeSlowdown(snapshots: snapshots, now: now), isTrue);
    });

    test('false quando a taxa das últimas 24h é normal', () {
      final snapshots = [
        for (var d = 1; d <= 7; d++)
          _snap('a', now.subtract(Duration(days: d)), 14),
        _snap('a', now.subtract(const Duration(hours: 12)), 14),
      ];
      expect(isFeeSlowdown(snapshots: snapshots, now: now), isFalse);
    });

    test('false sem média de base suficiente (posição nova/sem fees)', () {
      expect(isFeeSlowdown(snapshots: const [], now: now), isFalse);
    });
  });

  group('detectFeeSlowdowns', () {
    final now = DateTime(2026, 2, 1, 12);

    test('alerta só na transição para abrandamento', () {
      final positions = [_position(key: 'a')];
      final snapshots = {
        'a': [
          for (var d = 1; d <= 7; d++)
            _snap('a', now.subtract(Duration(days: d)), 14),
          _snap('a', now.subtract(const Duration(hours: 12)), 1),
        ],
      };

      final firstCheck = detectFeeSlowdowns(
        positions: positions,
        snapshotsByKey: snapshots,
        previousSlowdownByKey: {},
        now: now,
      );
      expect(firstCheck, hasLength(1));
      expect(firstCheck.first.kind, AlertKind.feeSlowdown);

      final secondCheck = detectFeeSlowdowns(
        positions: positions,
        snapshotsByKey: snapshots,
        previousSlowdownByKey: {'a': true},
        now: now,
      );
      expect(secondCheck, isEmpty);
    });

    test('ignora posições fechadas', () {
      final positions = [_position(key: 'a', isClosed: true)];
      final snapshots = {
        'a': [
          for (var d = 1; d <= 7; d++)
            _snap('a', now.subtract(Duration(days: d)), 14),
        ],
      };
      final alerts = detectFeeSlowdowns(
        positions: positions,
        snapshotsByKey: snapshots,
        previousSlowdownByKey: {},
        now: now,
      );
      expect(alerts, isEmpty);
    });
  });

  group('detectPriceThresholdCrossings', () {
    test('alerta quando o tick cruza para acima do threshold', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      final alerts = detectPriceThresholdCrossings(
        positions: positions,
        ruleByPositionKey: {
          'a': _rule(
            positionKey: 'a',
            thresholdTick: 100,
            direction: PriceAlertDirection.above,
          ),
        },
      );
      expect(alerts, hasLength(1));
      expect(alerts.first.kind, AlertKind.priceThreshold);
    });

    test('não repete enquanto lastTriggered já está true', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      final alerts = detectPriceThresholdCrossings(
        positions: positions,
        ruleByPositionKey: {
          'a': _rule(
            positionKey: 'a',
            thresholdTick: 100,
            direction: PriceAlertDirection.above,
            lastTriggered: true,
          ),
        },
      );
      expect(alerts, isEmpty);
    });

    test('ignora regras desativadas ou posições sem regra', () {
      final positions = [_position(key: 'a', currentTick: 150)];
      expect(
        detectPriceThresholdCrossings(
          positions: positions,
          ruleByPositionKey: {
            'a': _rule(
              positionKey: 'a',
              thresholdTick: 100,
              direction: PriceAlertDirection.above,
              enabled: false,
            ),
          },
        ),
        isEmpty,
      );
      expect(
        detectPriceThresholdCrossings(
          positions: positions,
          ruleByPositionKey: {},
        ),
        isEmpty,
      );
    });

    test('direção "below" alerta quando o tick cai abaixo do threshold', () {
      final positions = [_position(key: 'a', currentTick: -150)];
      final alerts = detectPriceThresholdCrossings(
        positions: positions,
        ruleByPositionKey: {
          'a': _rule(
            positionKey: 'a',
            thresholdTick: -100,
            direction: PriceAlertDirection.below,
          ),
        },
      );
      expect(alerts, hasLength(1));
    });
  });
}

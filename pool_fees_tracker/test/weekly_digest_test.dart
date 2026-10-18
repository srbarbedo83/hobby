import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/weekly_digest.dart';
import 'package:pool_fees_tracker/core/format/currency_formatter.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  double liquidityUsd = 1000,
  double feesClaimedUsd = 0,
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
    ..tickLower = -100
    ..tickUpper = 100
    ..currentTick = 0
    ..entryTick = 0
    ..liquidityUsd = liquidityUsd
    ..initialLiquidityUsd = liquidityUsd
    ..feesClaimedUsd = feesClaimedUsd
    ..feesUnclaimedUsd = 0
    ..gasCostUsd = 0
    ..isClosed = false;
}

FeeSnapshot _snap(String key, DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = key
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  final now = DateTime(2026, 2, 10, 12);

  group('computeWeeklyDigest', () {
    test('soma só os fees dos últimos 7 dias, de todas as posições', () {
      final positions = [_position(key: 'a'), _position(key: 'b')];
      final snapshots = {
        'a': [
          _snap('a', now.subtract(const Duration(days: 2)), 10),
          _snap('a', now.subtract(const Duration(days: 10)), 999),
        ],
        'b': [_snap('b', now.subtract(const Duration(days: 1)), 5)],
      };
      final digest = computeWeeklyDigest(
        positions: positions,
        snapshotsByKey: snapshots,
        now: now,
      );
      expect(digest.feesLast7dUsd, 15);
    });

    test('bestApr é null sem posições abertas', () {
      final digest = computeWeeklyDigest(
        positions: const [],
        snapshotsByKey: const {},
        now: now,
      );
      expect(digest.bestApr, isNull);
      expect(digest.feesLast7dUsd, 0);
    });
  });

  group('shouldSendWeeklyDigest', () {
    test('verdadeiro se nunca foi enviado', () {
      expect(shouldSendWeeklyDigest(lastSentAt: null, now: now), isTrue);
    });

    test('falso se foi enviado há menos de 7 dias', () {
      expect(
        shouldSendWeeklyDigest(
          lastSentAt: now.subtract(const Duration(days: 3)),
          now: now,
        ),
        isFalse,
      );
    });

    test('verdadeiro se já passou uma semana ou mais', () {
      expect(
        shouldSendWeeklyDigest(
          lastSentAt: now.subtract(const Duration(days: 7)),
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('buildWeeklyDigestBody', () {
    test('inclui o total de fees e a APR média, formatados', () {
      const digest = WeeklyDigest(
        feesLast7dUsd: 42.5,
        avgAprPct: 12.3,
        bestApr: null,
      );
      final body = buildWeeklyDigestBody(digest, CurrencyFormatter('USD'));
      expect(body, contains('42.50'));
      expect(body, contains('12.3%'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/dashboard_metrics.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  double liquidityUsd = 1000,
  double feesClaimedUsd = 10,
  double feesUnclaimedUsd = 5,
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
    ..tickLower = -100
    ..tickUpper = 100
    ..currentTick = 0
    ..entryTick = 0
    ..liquidityUsd = liquidityUsd
    ..initialLiquidityUsd = liquidityUsd
    ..feesClaimedUsd = feesClaimedUsd
    ..feesUnclaimedUsd = feesUnclaimedUsd
    ..gasCostUsd = 0
    ..isClosed = isClosed;
}

FeeSnapshot _snap(String key, DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = key
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  group('computeDashboardMetrics', () {
    final now = DateTime(2026, 2, 1, 12);

    test('soma fees e unclaimed através de todas as posições', () {
      final positions = [
        _position(key: 'a', feesClaimedUsd: 10, feesUnclaimedUsd: 5),
        _position(key: 'b', feesClaimedUsd: 20, feesUnclaimedUsd: 8),
      ];
      final metrics = computeDashboardMetrics(
        positions: positions,
        snapshotsByKey: {},
        now: now,
      );
      expect(metrics.totalFeesUsd, 43);
      expect(metrics.unclaimedUsd, 13);
    });

    test(
      'fees24h soma só os snapshots das últimas 24h, de todas as posições',
      () {
        final positions = [_position(key: 'a'), _position(key: 'b')];
        final snapshotsByKey = {
          'a': [
            _snap('a', now.subtract(const Duration(hours: 2)), 4),
            _snap('a', now.subtract(const Duration(days: 3)), 99),
          ],
          'b': [_snap('b', now.subtract(const Duration(hours: 10)), 6)],
        };
        final metrics = computeDashboardMetrics(
          positions: positions,
          snapshotsByKey: snapshotsByKey,
          now: now,
        );
        expect(metrics.fees24hUsd, 10);
      },
    );

    test('pctChangeVsPrevWeek é null sem dados da semana anterior', () {
      final positions = [_position(key: 'a')];
      final snapshotsByKey = {
        'a': [_snap('a', now.subtract(const Duration(days: 2)), 50)],
      };
      final metrics = computeDashboardMetrics(
        positions: positions,
        snapshotsByKey: snapshotsByKey,
        now: now,
      );
      expect(metrics.pctChangeVsPrevWeek, isNull);
    });

    test('pctChangeVsPrevWeek compara as duas semanas corretamente', () {
      final positions = [_position(key: 'a')];
      final snapshotsByKey = {
        'a': [
          _snap(
            'a',
            now.subtract(const Duration(days: 2)),
            150,
          ), // última semana
          _snap(
            'a',
            now.subtract(const Duration(days: 10)),
            100,
          ), // semana anterior
        ],
      };
      final metrics = computeDashboardMetrics(
        positions: positions,
        snapshotsByKey: snapshotsByKey,
        now: now,
      );
      expect(metrics.pctChangeVsPrevWeek, closeTo(50.0, 0.001));
    });

    test('posições fechadas continuam a contar para o total vitalício '
        '(coleta/fecho não faz o número descer, ao contrário do que a Krystal parece fazer)', () {
      final positions = [
        _position(key: 'open', feesClaimedUsd: 100, feesUnclaimedUsd: 20),
        _position(
          key: 'closed',
          liquidityUsd: 0,
          feesClaimedUsd: 145.30,
          feesUnclaimedUsd: 0,
          isClosed: true,
        ),
      ];
      final metrics = computeDashboardMetrics(
        positions: positions,
        snapshotsByKey: {},
        now: now,
      );
      expect(metrics.totalFeesUsd, closeTo(265.30, 0.001));
    });

    test('posições fechadas (liquidez 0) não distorcem a média de APR', () {
      final positions = [
        _position(key: 'open', liquidityUsd: 10000),
        _position(key: 'closed', liquidityUsd: 0, isClosed: true),
      ];
      final snapshotsByKey = {
        'open': [_snap('open', now.subtract(const Duration(days: 2)), 70)],
      };
      final metrics = computeDashboardMetrics(
        positions: positions,
        snapshotsByKey: snapshotsByKey,
        now: now,
      );
      // Só a posição aberta entra no cálculo (a fechada tem liquidityUsd
      // 0 e seria uma divisão por zero/infinito se contasse).
      expect(metrics.avgAprPct, closeTo(36.5, 0.01));
    });

    test('lista de posições vazia não rebenta nada', () {
      final metrics = computeDashboardMetrics(
        positions: [],
        snapshotsByKey: {},
        now: now,
      );
      expect(metrics.totalFeesUsd, 0);
      expect(metrics.avgAprPct, 0);
    });
  });
}

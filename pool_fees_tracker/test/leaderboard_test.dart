import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/leaderboard.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  double liquidityUsd = 1000,
  int entryTick = 0,
  int currentTick = 0,
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
    ..tickLower = -1000
    ..tickUpper = 1000
    ..currentTick = currentTick
    ..entryTick = entryTick
    ..liquidityUsd = liquidityUsd
    ..initialLiquidityUsd = liquidityUsd
    ..feesClaimedUsd = 0
    ..feesUnclaimedUsd = 0
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
  final now = DateTime(2026, 2, 1, 12);

  test('escolhe a posição com maior APR e a com maior perda de IL', () {
    final positions = [
      _position(key: 'low-apr-no-il', liquidityUsd: 1000),
      _position(key: 'high-apr-no-il', liquidityUsd: 1000),
      _position(
        key: 'low-apr-high-il',
        liquidityUsd: 1000,
        entryTick: 0,
        currentTick: 5000,
      ),
    ];
    final snapshots = {
      'low-apr-no-il': [
        _snap('low-apr-no-il', now.subtract(const Duration(days: 1)), 1.0),
      ],
      'high-apr-no-il': [
        _snap('high-apr-no-il', now.subtract(const Duration(days: 1)), 50.0),
      ],
      'low-apr-high-il': <FeeSnapshot>[],
    };

    final result = computeLeaderboard(
      positions: positions,
      snapshotsByKey: snapshots,
      now: now,
    );

    expect(result.bestApr?.position.positionKey, 'high-apr-no-il');
    expect(result.worstIl?.position.positionKey, 'low-apr-high-il');
  });

  test('ignora posições fechadas', () {
    final positions = [
      _position(key: 'open', liquidityUsd: 1000),
      _position(key: 'closed', liquidityUsd: 1000, isClosed: true),
    ];
    final result = computeLeaderboard(
      positions: positions,
      snapshotsByKey: {},
      now: now,
    );
    expect(result.bestApr?.position.positionKey, 'open');
  });

  test('lista vazia (sem posições abertas) devolve null em ambos', () {
    final result = computeLeaderboard(
      positions: [_position(key: 'closed', isClosed: true)],
      snapshotsByKey: {},
      now: now,
    );
    expect(result.bestApr, isNull);
    expect(result.worstIl, isNull);
  });
}

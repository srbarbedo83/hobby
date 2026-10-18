import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/pool_metrics.dart';
import 'package:pool_fees_tracker/core/export/position_summary.dart';
import 'package:pool_fees_tracker/core/format/currency_formatter.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position() {
  return PoolPosition()
    ..positionKey = 'p1'
    ..chain = Chain.ethereum
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = 'ETH'
    ..token1Symbol = 'USDC'
    ..feeTierBps = 500
    ..createdAt = DateTime(2026, 1, 1)
    ..tickLower = -100
    ..tickUpper = 100
    ..currentTick = 0
    ..entryTick = 0
    ..liquidityUsd = 1000
    ..initialLiquidityUsd = 1000
    ..feesClaimedUsd = 50
    ..feesUnclaimedUsd = 10
    ..gasCostUsd = 0;
}

void main() {
  test('inclui o par, as taxas, a APR e o estado do range', () {
    final position = _position();
    final metrics = computePoolMetrics(
      position: position,
      snapshots: const [],
      now: DateTime(2026, 2, 1),
    );
    final summary = buildPositionSummaryText(
      position: position,
      metrics: metrics,
      formatter: CurrencyFormatter('USD'),
    );
    expect(summary, contains('ETH/USDC'));
    expect(summary, contains('\$60.00'));
    expect(summary, contains('em range'));
  });
}

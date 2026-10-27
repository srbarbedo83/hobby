import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/close_now_simulation.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  double liquidityUsd = 1000,
  double initialLiquidityUsd = 900,
  double feesClaimedUsd = 0,
  double feesUnclaimedUsd = 0,
  double gasCostUsd = 10,
}) {
  return PoolPosition()
    ..positionKey = 'a'
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
    ..initialLiquidityUsd = initialLiquidityUsd
    ..feesClaimedUsd = feesClaimedUsd
    ..feesUnclaimedUsd = feesUnclaimedUsd
    ..gasCostUsd = gasCostUsd
    ..isClosed = false;
}

void main() {
  group('computeCloseNowSimulation', () {
    test('gás estimado de saída assume o mesmo valor do gás de abertura', () {
      final sim = computeCloseNowSimulation(
        position: _position(gasCostUsd: 12),
      );
      expect(sim.estimatedCloseGasUsd, 12);
    });

    test('valor recebido é a posição + fees reclamadas - gás de saída', () {
      final sim = computeCloseNowSimulation(
        position: _position(
          liquidityUsd: 1000,
          feesClaimedUsd: 30,
          gasCostUsd: 10,
        ),
      );
      expect(sim.netReceivedUsd, 1000 + 30 - 10);
    });

    test(
      'lucro desde a abertura conta capital inicial e o gás de abrir+fechar',
      () {
        final sim = computeCloseNowSimulation(
          position: _position(
            liquidityUsd: 1000,
            initialLiquidityUsd: 900,
            feesClaimedUsd: 30,
            gasCostUsd: 10,
          ),
        );
        // netReceived = 1000 + 30 - 10 = 1020
        // netProfit = 1020 - 900 - 10 = 110
        expect(sim.netProfitSinceOpenUsd, 110);
      },
    );

    test('posição em perda dá lucro negativo', () {
      final sim = computeCloseNowSimulation(
        position: _position(
          liquidityUsd: 500,
          initialLiquidityUsd: 900,
          feesClaimedUsd: 0,
          gasCostUsd: 10,
        ),
      );
      expect(sim.netProfitSinceOpenUsd, lessThan(0));
    });
  });
}

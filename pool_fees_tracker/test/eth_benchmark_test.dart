import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/eth_benchmark.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  required String token0Symbol,
  required String token1Symbol,
  required int entryTick,
  required int currentTick,
  double initialLiquidityUsd = 1000,
  double liquidityUsd = 1000,
  double feesClaimedUsd = 0,
  bool isClosed = false,
}) {
  return PoolPosition()
    ..positionKey = key
    ..chain = Chain.ethereum
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = token0Symbol
    ..token1Symbol = token1Symbol
    ..feeTierBps = 500
    ..createdAt = DateTime(2025, 1, 1)
    ..tickLower = -100000
    ..tickUpper = 100000
    ..currentTick = currentTick
    ..entryTick = entryTick
    ..liquidityUsd = liquidityUsd
    ..initialLiquidityUsd = initialLiquidityUsd
    ..feesClaimedUsd = feesClaimedUsd
    ..feesUnclaimedUsd = 0
    ..gasCostUsd = 0
    ..isClosed = isClosed;
}

void main() {
  group('computeEthBenchmark', () {
    test('sem posições elegíveis (nenhum par ETH/stablecoin) dá null', () {
      final positions = [
        _position(
          key: 'a',
          token0Symbol: 'WBTC',
          token1Symbol: 'USDC',
          entryTick: 0,
          currentTick: 0,
        ),
      ];
      expect(computeEthBenchmark(positions), isNull);
    });

    test('lista vazia dá null', () {
      expect(computeEthBenchmark(const []), isNull);
    });

    test('ignora posições fechadas', () {
      final positions = [
        _position(
          key: 'a',
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          entryTick: 0,
          currentTick: 0,
          isClosed: true,
        ),
      ];
      expect(computeEthBenchmark(positions), isNull);
    });

    test(
      'ETH a subir desde a entrada dá ethHodlValueUsd maior que o inicial',
      () {
        // tick maior = preço token1/token0 maior = ETH mais caro em USD.
        final positions = [
          _position(
            key: 'a',
            token0Symbol: 'ETH',
            token1Symbol: 'USDC',
            entryTick: 0,
            currentTick: 1000,
            initialLiquidityUsd: 1000,
          ),
        ];
        final result = computeEthBenchmark(positions)!;
        expect(result.ethHodlValueUsd, greaterThan(1000));
        expect(result.eligiblePositionsCount, 1);
      },
    );

    test('funciona com ETH como token1 (preço invertido)', () {
      final positions = [
        _position(
          key: 'a',
          token0Symbol: 'USDC',
          token1Symbol: 'ETH',
          entryTick: 0,
          currentTick: -1000,
          initialLiquidityUsd: 1000,
        ),
      ];
      final result = computeEthBenchmark(positions)!;
      // tick desce = token1 (ETH) por token0 (USDC) desce = ETH mais barato
      // em termos de USDC... na verdade o preço token1/token0 descer
      // significa que 1 USDC compra menos ETH, ou seja, ETH subiu.
      expect(result.ethHodlValueUsd, greaterThan(1000));
    });

    test('net vs ETH é a diferença entre o valor do portfolio e o hodl', () {
      final positions = [
        _position(
          key: 'a',
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          entryTick: 0,
          currentTick: 0,
          initialLiquidityUsd: 1000,
          liquidityUsd: 1200,
          feesClaimedUsd: 50,
        ),
      ];
      final result = computeEthBenchmark(positions)!;
      expect(result.portfolioValueUsd, 1250);
      expect(result.ethHodlValueUsd, 1000);
      expect(result.netVsEthUsd, 250);
    });
  });
}

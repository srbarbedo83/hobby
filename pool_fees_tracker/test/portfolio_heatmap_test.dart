import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/portfolio_heatmap.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required String key,
  required Chain chain,
  required String token0Symbol,
  required String token1Symbol,
  required double liquidityUsd,
  bool isClosed = false,
}) {
  return PoolPosition()
    ..positionKey = key
    ..chain = chain
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = token0Symbol
    ..token1Symbol = token1Symbol
    ..feeTierBps = 500
    ..createdAt = DateTime(2025, 1, 1)
    ..tickLower = -100
    ..tickUpper = 100
    ..currentTick = 0
    ..entryTick = 0
    ..liquidityUsd = liquidityUsd
    ..initialLiquidityUsd = liquidityUsd
    ..feesClaimedUsd = 0
    ..feesUnclaimedUsd = 0
    ..gasCostUsd = 0
    ..isClosed = isClosed;
}

void main() {
  group('computePortfolioHeatmap', () {
    test('lista vazia dá lista vazia', () {
      expect(computePortfolioHeatmap(const []), isEmpty);
    });

    test('ignora posições fechadas', () {
      final positions = [
        _position(
          key: 'a',
          chain: Chain.ethereum,
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidityUsd: 1000,
          isClosed: true,
        ),
      ];
      expect(computePortfolioHeatmap(positions), isEmpty);
    });

    test('agrupa pelo mesmo chain+par e soma os valores', () {
      final positions = [
        _position(
          key: 'a',
          chain: Chain.ethereum,
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidityUsd: 600,
        ),
        _position(
          key: 'b',
          chain: Chain.ethereum,
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidityUsd: 400,
        ),
      ];
      final cells = computePortfolioHeatmap(positions);
      expect(cells, hasLength(1));
      expect(cells.first.valueUsd, 1000);
      expect(cells.first.pctOfTotal, 100);
    });

    test('separa a mesma chain+par de chains diferentes', () {
      final positions = [
        _position(
          key: 'a',
          chain: Chain.ethereum,
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidityUsd: 700,
        ),
        _position(
          key: 'b',
          chain: Chain.arbitrum,
          token0Symbol: 'ETH',
          token1Symbol: 'USDC',
          liquidityUsd: 300,
        ),
      ];
      final cells = computePortfolioHeatmap(positions);
      expect(cells, hasLength(2));
      expect(cells.first.valueUsd, 700);
      expect(cells.first.pctOfTotal, 70);
      expect(cells.last.valueUsd, 300);
      expect(cells.last.pctOfTotal, 30);
    });

    test('ordena do maior para o menor valor', () {
      final positions = [
        _position(
          key: 'a',
          chain: Chain.ethereum,
          token0Symbol: 'A',
          token1Symbol: 'B',
          liquidityUsd: 100,
        ),
        _position(
          key: 'b',
          chain: Chain.ethereum,
          token0Symbol: 'C',
          token1Symbol: 'D',
          liquidityUsd: 900,
        ),
      ];
      final cells = computePortfolioHeatmap(positions);
      expect(cells.first.pairLabel, 'C/D');
      expect(cells.last.pairLabel, 'A/B');
    });
  });
}

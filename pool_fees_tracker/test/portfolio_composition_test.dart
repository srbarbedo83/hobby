import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/portfolio_composition.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

PoolPosition _position({
  required Chain chain,
  required String token0,
  required String token1,
  required double liquidityUsd,
  bool isClosed = false,
}) {
  return PoolPosition()
    ..positionKey = '$chain:$token0$token1:$liquidityUsd'
    ..chain = chain
    ..walletAddress = '0xabc'
    ..tokenIdOnChain = '1'
    ..token0Symbol = token0
    ..token1Symbol = token1
    ..feeTierBps = 500
    ..createdAt = DateTime(2026, 1, 1)
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
  test('compositionByChain soma o valor por chain, maior primeiro', () {
    final positions = [
      _position(
        chain: Chain.ethereum,
        token0: 'ETH',
        token1: 'USDC',
        liquidityUsd: 100,
      ),
      _position(
        chain: Chain.arbitrum,
        token0: 'ARB',
        token1: 'ETH',
        liquidityUsd: 300,
      ),
      _position(
        chain: Chain.ethereum,
        token0: 'WBTC',
        token1: 'ETH',
        liquidityUsd: 50,
      ),
    ];
    final result = compositionByChain(positions);
    expect(result.first.label, 'Arbitrum');
    expect(result.first.valueUsd, 300);
    expect(result.last.label, 'Ethereum');
    expect(result.last.valueUsd, 150);
  });

  test(
    'compositionByPair agrega pelo par de tokens, ignora posições fechadas',
    () {
      final positions = [
        _position(
          chain: Chain.ethereum,
          token0: 'ETH',
          token1: 'USDC',
          liquidityUsd: 100,
        ),
        _position(
          chain: Chain.ethereum,
          token0: 'ETH',
          token1: 'USDC',
          liquidityUsd: 9999,
          isClosed: true,
        ),
      ];
      final result = compositionByPair(positions);
      expect(result, hasLength(1));
      expect(result.single.label, 'ETH / USDC');
      expect(result.single.valueUsd, 100);
    },
  );
}

import '../../data/local/pool_position.dart';
import 'univ3_fee_math.dart';

const _ethSymbols = {'ETH', 'WETH'};
const _stableSymbols = {'USDC', 'USDT', 'DAI', 'USDC.E', 'USDBC'};

/// `true` só para pares ETH/stablecoin — os únicos onde o preço do par
/// (token1 por token0) é, na prática, o preço de ETH em USD, sem
/// precisar de um histórico de preço separado que a app não guarda. Um
/// par sem ETH, ou ETH contra outro token volátil, fica de fora: não há
/// forma honesta de estimar "o que valeria em ETH" sem esse dado.
bool _isEthStablePair(PoolPosition p) {
  final isEthStable =
      _ethSymbols.contains(p.token0Symbol) &&
      _stableSymbols.contains(p.token1Symbol);
  final isStableEth =
      _stableSymbols.contains(p.token0Symbol) &&
      _ethSymbols.contains(p.token1Symbol);
  return isEthStable || isStableEth;
}

/// Preço de ETH em USD a um dado tick, para posições ETH/stablecoin —
/// `priceAtTick` dá token1 por token0, por isso inverte-se quando ETH é
/// o token1.
double _ethUsdPriceAtTick(PoolPosition p, num tick) {
  final price = priceAtTick(
    tick: tick,
    token0Decimals: p.token0Decimals,
    token1Decimals: p.token1Decimals,
  );
  return _ethSymbols.contains(p.token0Symbol) ? price : 1 / price;
}

class EthBenchmarkResult {
  /// Valor atual das posições elegíveis (ETH/stablecoin): valor da
  /// posição (já inclui fees não reclamadas) + fees já reclamadas.
  final double portfolioValueUsd;

  /// O que esse mesmo capital inicial valeria agora se, em vez de dar
  /// liquidez, tivesse só comprado ETH no momento de abertura de cada
  /// posição e continuado a guardá-lo.
  final double ethHodlValueUsd;

  /// Quantas posições entraram neste cálculo — só pares ETH/stablecoin.
  final int eligiblePositionsCount;

  double get netVsEthUsd => portfolioValueUsd - ethHodlValueUsd;

  const EthBenchmarkResult({
    required this.portfolioValueUsd,
    required this.ethHodlValueUsd,
    required this.eligiblePositionsCount,
  });
}

/// `null` quando não há nenhuma posição aberta num par ETH/stablecoin —
/// não há como comparar com ETH sem pelo menos uma.
EthBenchmarkResult? computeEthBenchmark(List<PoolPosition> positions) {
  final eligible = positions
      .where((p) => !p.isClosed && _isEthStablePair(p))
      .toList();
  if (eligible.isEmpty) return null;

  var portfolioValueUsd = 0.0;
  var ethHodlValueUsd = 0.0;
  for (final p in eligible) {
    portfolioValueUsd += p.liquidityUsd + p.feesClaimedUsd;

    final entryEthUsd = _ethUsdPriceAtTick(p, p.entryTick);
    final currentEthUsd = _ethUsdPriceAtTick(p, p.currentTick);
    ethHodlValueUsd += entryEthUsd > 0
        ? p.initialLiquidityUsd * (currentEthUsd / entryEthUsd)
        : p.initialLiquidityUsd;
  }

  return EthBenchmarkResult(
    portfolioValueUsd: portfolioValueUsd,
    ethHodlValueUsd: ethHodlValueUsd,
    eligiblePositionsCount: eligible.length,
  );
}

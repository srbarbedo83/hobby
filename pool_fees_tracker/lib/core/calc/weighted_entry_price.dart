import '../../data/local/pool_position.dart';
import 'univ3_fee_math.dart';

/// Preço médio de entrada, ponderado pelo capital inicial de cada posição
/// — útil quando o mesmo par (mesma chain, mesmos tokens) tem mais do que
/// uma posição aberta (ex.: reentrou depois de fechar, ou mantém várias
/// ranges em paralelo) e queres saber o teu ponto de entrada combinado,
/// não só o de cada posição isolada.
///
/// `null` sem posições, ou se todas tiverem capital inicial 0 (nada para
/// ponderar). Assume que todas as posições passadas já são do mesmo par —
/// quem chama é responsável por agrupar por chain + token0/token1 antes.
double? weightedAverageEntryPrice(List<PoolPosition> positions) {
  if (positions.isEmpty) return null;
  final totalWeight = positions.fold<double>(
    0,
    (a, p) => a + p.initialLiquidityUsd,
  );
  if (totalWeight <= 0) return null;

  final weightedTick =
      positions.fold<double>(
        0,
        (a, p) => a + p.entryTick * p.initialLiquidityUsd,
      ) /
      totalWeight;

  final first = positions.first;
  return priceAtTick(
    tick: weightedTick,
    token0Decimals: first.token0Decimals,
    token1Decimals: first.token1Decimals,
  );
}

import '../../data/local/chain.dart';
import '../../data/local/pool_position.dart';

/// Uma célula do heatmap: quanto do valor total da carteira está num
/// cruzamento (chain, par) específico — mais fino do que os donuts de
/// composição existentes (que só olham a UMA dimensão de cada vez, chain
/// OU par, nunca as duas juntas).
class HeatmapCell {
  final Chain chain;
  final String pairLabel;
  final double valueUsd;
  final double pctOfTotal;

  const HeatmapCell({
    required this.chain,
    required this.pairLabel,
    required this.valueUsd,
    required this.pctOfTotal,
  });
}

/// Agrega o valor (liquidez, já inclui fees não reclamadas) por
/// combinação de chain + par de tokens, só posições abertas — ordenado
/// do maior para o menor, para a UI destacar logo onde está a maior
/// concentração.
List<HeatmapCell> computePortfolioHeatmap(List<PoolPosition> positions) {
  final open = positions.where((p) => !p.isClosed).toList();
  final totalValueUsd = open.fold<double>(0, (a, p) => a + p.liquidityUsd);
  if (totalValueUsd <= 0) return const [];

  final sums = <String, double>{};
  final chainByKey = <String, Chain>{};
  final pairByKey = <String, String>{};
  for (final p in open) {
    final pairLabel = '${p.token0Symbol}/${p.token1Symbol}';
    final key = '${p.chain.name}:$pairLabel';
    sums[key] = (sums[key] ?? 0) + p.liquidityUsd;
    chainByKey[key] = p.chain;
    pairByKey[key] = pairLabel;
  }

  final cells = [
    for (final entry in sums.entries)
      HeatmapCell(
        chain: chainByKey[entry.key]!,
        pairLabel: pairByKey[entry.key]!,
        valueUsd: entry.value,
        pctOfTotal: entry.value / totalValueUsd * 100,
      ),
  ];
  cells.sort((a, b) => b.valueUsd.compareTo(a.valueUsd));
  return cells;
}

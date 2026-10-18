import '../../data/local/chain.dart';
import '../../data/local/pool_position.dart';

class CompositionSlice {
  final String label;
  final double valueUsd;

  const CompositionSlice({required this.label, required this.valueUsd});
}

List<CompositionSlice> _sortedByValueDesc(Map<String, double> sums) {
  final slices = [
    for (final entry in sums.entries)
      CompositionSlice(label: entry.key, valueUsd: entry.value),
  ];
  slices.sort((a, b) => b.valueUsd.compareTo(a.valueUsd));
  return slices;
}

/// % do valor total (fees + liquidez) por chain — só posições abertas, tal
/// como a lista "Your Pools" (fechadas já não têm valor ativo a reportar).
List<CompositionSlice> compositionByChain(List<PoolPosition> positions) {
  final sums = <String, double>{};
  for (final p in positions.where((p) => !p.isClosed)) {
    sums[p.chain.displayName] =
        (sums[p.chain.displayName] ?? 0) + p.liquidityUsd;
  }
  return _sortedByValueDesc(sums);
}

/// % do valor total por par de tokens (não por token individual — a app
/// não sabe a divisão exata token0/token1 dentro de uma posição v3 sem a
/// fórmula de liquidez completa, por isso agrega ao nível do par, que é
/// um número real, não uma divisão inventada).
List<CompositionSlice> compositionByPair(List<PoolPosition> positions) {
  final sums = <String, double>{};
  for (final p in positions.where((p) => !p.isClosed)) {
    final key = '${p.token0Symbol} / ${p.token1Symbol}';
    sums[key] = (sums[key] ?? 0) + p.liquidityUsd;
  }
  return _sortedByValueDesc(sums);
}

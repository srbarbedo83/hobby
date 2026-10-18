/// Liquidez bruta inicializada num tick da pool — ver
/// `UniswapSubgraphClient.fetchLiquidityProfile` (Live) ou a geração
/// sintética do repositório Demo.
class TickLiquidity {
  final int tick;
  final double liquidityGross;

  const TickLiquidity({required this.tick, required this.liquidityGross});
}

/// Que fração da liquidez total numa janela ao redor do range está
/// DENTRO do próprio range da posição — uma pista de quão "concorrida"
/// está essa zona de preço (muitos outros LPs a competir pelas mesmas
/// fees) ou não.
///
/// Aproximação: a liquidez de cada tick vem da pool toda — inclui a
/// própria liquidez desta posição, que o subgraph não dá separada do
/// resto. Numa pool com muitos LPs isto tem pouco impacto; numa pool
/// pequena onde esta posição seja grande parte da liquidez, a
/// percentagem fica inflacionada pela própria posição.
double computeRangeConcentrationPct({
  required List<TickLiquidity> profile,
  required int tickLower,
  required int tickUpper,
}) {
  if (profile.isEmpty) return 0;
  final total = profile.fold<double>(0, (a, b) => a + b.liquidityGross);
  if (total <= 0) return 0;
  final inRange = profile
      .where((t) => t.tick >= tickLower && t.tick <= tickUpper)
      .fold<double>(0, (a, b) => a + b.liquidityGross);
  return inRange / total * 100;
}

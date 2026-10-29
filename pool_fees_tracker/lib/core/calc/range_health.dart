enum RangeStatus { inRange, nearEdge, outOfRange }

class RangeHealth {
  /// 0.0 = no tick inferior do range, 1.0 = no tick superior.
  /// Pode ser < 0 ou > 1 quando o preço já saiu do range.
  final double positionFraction;
  final RangeStatus status;

  const RangeHealth({required this.positionFraction, required this.status});
}

/// Calcula onde o tick atual está dentro do range [tickLower, tickUpper] da
/// posição, e classifica o estado: dentro do range, perto da margem (dentro
/// de [edgeThresholdPct] da largura do range), ou já fora.
RangeHealth computeRangeHealth({
  required int tickLower,
  required int tickUpper,
  required int currentTick,
  double edgeThresholdPct = 0.1,
}) {
  final width = tickUpper - tickLower;
  if (width <= 0) {
    return const RangeHealth(
      positionFraction: 0.5,
      status: RangeStatus.inRange,
    );
  }

  final fraction = (currentTick - tickLower) / width;

  if (fraction < 0 || fraction > 1) {
    return RangeHealth(
      positionFraction: fraction,
      status: RangeStatus.outOfRange,
    );
  }
  if (fraction < edgeThresholdPct || fraction > 1 - edgeThresholdPct) {
    return RangeHealth(
      positionFraction: fraction,
      status: RangeStatus.nearEdge,
    );
  }
  return RangeHealth(positionFraction: fraction, status: RangeStatus.inRange);
}

/// Mapeia [positionFraction] (pode ir muito além de 0..1 quando o preço
/// está fora do range) para uma posição visual limitada, para a
/// `RangeHealthBar` poder desenhar a bolinha fora da barra colorida sem
/// precisar de espaço ilimitado. Dentro do range é 1:1 (0..1). Fora do
/// range, o excesso é comprimido por uma curva que se aproxima de
/// [overflowFraction] mas nunca o ultrapassa — quanto mais fora, mais a
/// bolinha se aproxima do limite da margem reservada, sem nunca sair dela
/// (um excesso de 10x o range não ocupa 10x o espaço, só se aproxima mais
/// do limite).
double rangeDotPositionFraction(
  double positionFraction, {
  double overflowFraction = 0.25,
}) {
  if (positionFraction >= 0 && positionFraction <= 1) return positionFraction;
  final excess = positionFraction < 0 ? positionFraction : positionFraction - 1;
  final compressed = 1 - 1 / (1 + excess.abs());
  return positionFraction < 0
      ? -compressed * overflowFraction
      : 1 + compressed * overflowFraction;
}

import '../../data/local/price_point.dart';

/// Resultado de simular um range hipotético, de largura
/// `widthMultiplier`× a largura real da posição, centrado no tick de
/// entrada — usando o histórico de preço já gravado (ver `PricePoint`)
/// para saber que fração do tempo o preço teria ficado dentro.
class RangeSimulationResult {
  final double widthMultiplier;
  final int lowerTick;
  final int upperTick;

  /// Fração (0..1) do histórico de preço conhecido em que o tick estaria
  /// dentro deste range hipotético.
  final double fractionInRange;

  /// Multiplicador de concentração de fees ~ 1/largura: um range mais
  /// estreito ganha uma fração maior das fees da pool enquanto está
  /// dentro (mesma lógica de capital eficiente da Uniswap v3), mas passa
  /// mais tempo fora. Aproximação — não tem em conta a distribuição real
  /// de liquidez de outros LPs na pool.
  final double feeConcentrationMultiplier;

  /// `fractionInRange × feeConcentrationMultiplier`, normalizado para o
  /// range real (`widthMultiplier == 1.0`) valer 1.0 — "quantas vezes
  /// mais/menos fees relativas" este range hipotético teria dado.
  final double relativeFeeScore;

  const RangeSimulationResult({
    required this.widthMultiplier,
    required this.lowerTick,
    required this.upperTick,
    required this.fractionInRange,
    required this.feeConcentrationMultiplier,
    required this.relativeFeeScore,
  });
}

const defaultWidthMultipliers = [0.25, 0.5, 1.0, 2.0, 4.0];

List<RangeSimulationResult> simulateRangeWidths({
  required List<PricePoint> pricePoints,
  required int actualTickLower,
  required int actualTickUpper,
  required int entryTick,
  List<double> widthMultipliers = defaultWidthMultipliers,
}) {
  if (pricePoints.isEmpty) return [];
  final actualHalfWidth = (actualTickUpper - actualTickLower) / 2;
  if (actualHalfWidth <= 0) return [];

  double fractionFor(double halfWidth) {
    final lower = entryTick - halfWidth;
    final upper = entryTick + halfWidth;
    final inRangeCount = pricePoints
        .where((p) => p.tick >= lower && p.tick <= upper)
        .length;
    return inRangeCount / pricePoints.length;
  }

  // Score do range real (multiplier 1.0), para normalizar os outros.
  final baselineFraction = fractionFor(actualHalfWidth);
  final baselineScore = baselineFraction * 1.0;

  final results = <RangeSimulationResult>[];
  for (final multiplier in widthMultipliers) {
    final halfWidth = actualHalfWidth * multiplier;
    final fraction = fractionFor(halfWidth);
    final concentration = 1 / multiplier;
    final rawScore = fraction * concentration;
    results.add(
      RangeSimulationResult(
        widthMultiplier: multiplier,
        lowerTick: (entryTick - halfWidth).round(),
        upperTick: (entryTick + halfWidth).round(),
        fractionInRange: fraction,
        feeConcentrationMultiplier: concentration,
        relativeFeeScore: baselineScore <= 0 ? 0 : rawScore / baselineScore,
      ),
    );
  }
  return results;
}

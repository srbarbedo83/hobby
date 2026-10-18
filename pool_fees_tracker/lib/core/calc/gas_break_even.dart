class GasBreakEven {
  /// Verdadeiro se as fees acumuladas já cobriram o custo de gás da posição.
  final bool reached;

  /// Quanto falta ganhar em fees para atingir o break-even (0 se já atingido).
  final double remainingUsd;

  /// Estimativa de dias até ao break-even ao ritmo diário atual.
  /// `null` se já foi atingido, ou se o ritmo diário é demasiado baixo para
  /// estimar (seria indefinido/infinito).
  final int? estimatedDaysRemaining;

  const GasBreakEven({
    required this.reached,
    required this.remainingUsd,
    required this.estimatedDaysRemaining,
  });
}

GasBreakEven computeGasBreakEven({
  required double feesTotalUsd,
  required double gasCostUsd,
  required double avgDailyFeeUsd,
}) {
  final remaining = gasCostUsd - feesTotalUsd;
  if (remaining <= 0) {
    return const GasBreakEven(
      reached: true,
      remainingUsd: 0,
      estimatedDaysRemaining: null,
    );
  }
  final days = avgDailyFeeUsd > 0 ? (remaining / avgDailyFeeUsd).ceil() : null;
  return GasBreakEven(
    reached: false,
    remainingUsd: remaining,
    estimatedDaysRemaining: days,
  );
}

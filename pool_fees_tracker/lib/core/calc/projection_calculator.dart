class EarningsProjection {
  final double projectedEndOfMonthUsd;
  final double projectedEndOfYearUsd;

  const EarningsProjection({
    required this.projectedEndOfMonthUsd,
    required this.projectedEndOfYearUsd,
  });
}

/// Projeta o total de fees até ao fim do mês/ano corrente, assumindo que a
/// taxa diária média recente ([avgDailyFeeUsd]) se mantém. É uma estimativa
/// de tendência, não uma garantia — a taxa de uma pool varia com o volume.
EarningsProjection projectFromDailyRate({
  required double alreadyEarnedThisMonthUsd,
  required double alreadyEarnedThisYearUsd,
  required double avgDailyFeeUsd,
  required DateTime now,
}) {
  final firstOfNextMonth = now.month == 12
      ? DateTime(now.year + 1, 1, 1)
      : DateTime(now.year, now.month + 1, 1);
  final daysRemainingInMonth = firstOfNextMonth.difference(now).inHours / 24;

  final firstOfNextYear = DateTime(now.year + 1, 1, 1);
  final daysRemainingInYear = firstOfNextYear.difference(now).inHours / 24;

  return EarningsProjection(
    projectedEndOfMonthUsd:
        alreadyEarnedThisMonthUsd + avgDailyFeeUsd * daysRemainingInMonth,
    projectedEndOfYearUsd:
        alreadyEarnedThisYearUsd + avgDailyFeeUsd * daysRemainingInYear,
  );
}

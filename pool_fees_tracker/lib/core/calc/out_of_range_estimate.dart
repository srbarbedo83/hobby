import '../../data/local/pool_position.dart';
import '../../data/local/price_point.dart';
import 'price_history_calc.dart';

/// Quanto tempo uma posição está continuamente fora do range, e uma
/// estimativa de quantas fees ficaram "por ganhar" nesse tempo —
/// `null` quando a posição está dentro do range (nada a estimar).
///
/// Aproximação: a taxa diária histórica usada como referência é
/// `feesTotalUsd / dias em que a posição esteve dentro do range`
/// (dias totais menos os dias já fora do range) — assume que essa taxa se
/// teria mantido se a posição não tivesse saído do range. Não tem em conta
/// mudanças no volume da pool nesse período, só é uma referência do que
/// "costumava ganhar".
class OutOfRangeEstimate {
  final Duration duration;
  final double missedFeesUsd;

  const OutOfRangeEstimate({
    required this.duration,
    required this.missedFeesUsd,
  });
}

OutOfRangeEstimate? estimateMissedFees({
  required List<PricePoint> pricePoints,
  required int tickLower,
  required int tickUpper,
  required double feesTotalUsd,
  required DateTime createdAt,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final duration = currentOutOfRangeDuration(
    points: pricePoints,
    tickLower: tickLower,
    tickUpper: tickUpper,
    now: effectiveNow,
  );
  if (duration == null) return null;

  final totalDaysOpen = effectiveNow.difference(createdAt).inHours / 24;
  final daysOutOfRange = duration.inHours / 24;
  final daysInRange = (totalDaysOpen - daysOutOfRange).clamp(
    0.0,
    double.infinity,
  );
  if (daysInRange <= 0) {
    return OutOfRangeEstimate(duration: duration, missedFeesUsd: 0);
  }

  final historicalDailyRate = feesTotalUsd / daysInRange;
  return OutOfRangeEstimate(
    duration: duration,
    missedFeesUsd: historicalDailyRate * daysOutOfRange,
  );
}

/// Sugestão de um novo range (mesma largura, recentrado no preço atual)
/// quando a posição está fora do range há mais de [threshold] — um
/// alerta "isto já dura o suficiente para valer a pena considerar
/// mover". Não executa nada on-chain, é só uma sugestão de números.
class RebalanceSuggestion {
  final int newTickLower;
  final int newTickUpper;
  final OutOfRangeEstimate estimate;

  const RebalanceSuggestion({
    required this.newTickLower,
    required this.newTickUpper,
    required this.estimate,
  });
}

RebalanceSuggestion? suggestRebalance({
  required PoolPosition position,
  required OutOfRangeEstimate? estimate,
  Duration threshold = const Duration(hours: 24),
}) {
  if (estimate == null || estimate.duration < threshold) return null;
  final halfWidth = (position.tickUpper - position.tickLower) ~/ 2;
  return RebalanceSuggestion(
    newTickLower: position.currentTick - halfWidth,
    newTickUpper: position.currentTick + halfWidth,
    estimate: estimate,
  );
}

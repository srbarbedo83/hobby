import '../../data/local/pool_position.dart';
import 'range_health.dart';

enum AlertKind { outOfRange, feeMilestone }

class AlertEvent {
  final String positionKey;
  final AlertKind kind;
  final String title;
  final String body;

  /// Para [AlertKind.feeMilestone]: o novo valor de fees a guardar como
  /// "último avisado", para o próximo milestone só disparar depois de
  /// passado o threshold outra vez.
  final double? newNotifiedFeesTotal;

  const AlertEvent({
    required this.positionKey,
    required this.kind,
    required this.title,
    required this.body,
    this.newNotifiedFeesTotal,
  });
}

/// Compara o estado de range anterior com o atual e devolve um alerta para
/// cada posição que acabou de SAIR do range (transição, não o estado em
/// si — para não avisar repetidamente a cada verificação enquanto
/// continuar fora do range).
List<AlertEvent> detectRangeTransitions({
  required List<PoolPosition> positions,
  required Map<String, RangeStatus> previousStatusByKey,
}) {
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    if (position.isClosed) continue;
    final health = computeRangeHealth(
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
      currentTick: position.currentTick,
    );
    final previous = previousStatusByKey[position.positionKey];
    final justLeftRange =
        health.status == RangeStatus.outOfRange &&
        previous != RangeStatus.outOfRange;
    if (justLeftRange) {
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.outOfRange,
          title:
              '${position.token0Symbol}/${position.token1Symbol} is out of range',
          body: 'The price moved outside your position\'s range — it has stopped earning fees.',
        ),
      );
    }
  }
  return alerts;
}

/// Compara as fees totais atuais com o último valor avisado por posição;
/// dispara um alerta sempre que o acumulado passa para o próximo múltiplo
/// de [thresholdUsd] acima do que já foi avisado.
List<AlertEvent> detectFeeMilestones({
  required List<PoolPosition> positions,
  required Map<String, double> lastNotifiedFeesByKey,
  required double thresholdUsd,
}) {
  if (thresholdUsd <= 0) return [];
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    final lastNotified = lastNotifiedFeesByKey[position.positionKey] ?? 0;
    final total = position.feesTotalUsd;
    if (total >= lastNotified + thresholdUsd) {
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.feeMilestone,
          title:
              '${position.token0Symbol}/${position.token1Symbol} passed a fee milestone',
          body: 'Lifetime fees just passed \$${total.toStringAsFixed(2)}.',
          newNotifiedFeesTotal: total,
        ),
      );
    }
  }
  return alerts;
}

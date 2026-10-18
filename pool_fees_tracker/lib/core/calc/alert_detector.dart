import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/price_alert_rule.dart';
import 'range_health.dart';

enum AlertKind { outOfRange, feeMilestone, feeSlowdown, priceThreshold }

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
              '${position.token0Symbol}/${position.token1Symbol} está fora do range',
          body: 'O preço saiu do range desta posição — deixou de ganhar taxas.',
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
              '${position.token0Symbol}/${position.token1Symbol} passou um milestone de taxas',
          body:
              'As taxas vitalícias acabaram de passar \$${total.toStringAsFixed(2)}.',
          newNotifiedFeesTotal: total,
        ),
      );
    }
  }
  return alerts;
}

/// `true` quando as fees das últimas 24h estão bem abaixo da média diária
/// dos últimos 7 dias — sinal de que a pool pode estar a perder volume.
/// `false` também quando não há média de base suficiente para a
/// comparação fazer sentido (posição muito nova, ou sem fees ainda).
bool isFeeSlowdown({
  required List<FeeSnapshot> snapshots,
  double dropThresholdFraction = 0.5,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final last24hCutoff = effectiveNow.subtract(const Duration(hours: 24));
  final last7dCutoff = effectiveNow.subtract(const Duration(days: 7));
  final fees24h = snapshots
      .where((s) => s.timestamp.isAfter(last24hCutoff))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);
  final fees7d = snapshots
      .where((s) => s.timestamp.isAfter(last7dCutoff))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);
  final avgDaily7d = fees7d / 7;
  if (avgDaily7d <= 0.01) return false;
  return fees24h < avgDaily7d * dropThresholdFraction;
}

/// Compara o estado de abrandamento anterior com o atual e devolve um
/// alerta só para quem acabou de ENTRAR em abrandamento — mesma lógica de
/// "transição, não estado" de [detectRangeTransitions], para não reavisar
/// a cada verificação enquanto o abrandamento persistir.
List<AlertEvent> detectFeeSlowdowns({
  required List<PoolPosition> positions,
  required Map<String, List<FeeSnapshot>> snapshotsByKey,
  required Map<String, bool> previousSlowdownByKey,
  DateTime? now,
}) {
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    if (position.isClosed) continue;
    final snapshots = snapshotsByKey[position.positionKey] ?? const [];
    final slowdownNow = isFeeSlowdown(snapshots: snapshots, now: now);
    final wasSlowdown = previousSlowdownByKey[position.positionKey] ?? false;
    if (slowdownNow && !wasSlowdown) {
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.feeSlowdown,
          title:
              '${position.token0Symbol}/${position.token1Symbol} — taxas a abrandar',
          body:
              'As taxas das últimas 24h caíram bem abaixo da média de 7 dias desta '
              'posição — a pool pode estar a ter menos volume.',
        ),
      );
    }
  }
  return alerts;
}

/// `true` quando o tick atual já cumpre a condição da regra (acima/abaixo
/// do threshold) — usado tanto para decidir se alerta como para o valor
/// novo de `PriceAlertRule.lastTriggered` que o chamador persiste.
bool priceThresholdMet(PriceAlertRule rule, int currentTick) {
  return rule.direction == PriceAlertDirection.above
      ? currentTick >= rule.thresholdTick
      : currentTick <= rule.thresholdTick;
}

/// Alerta de preço definido pelo utilizador por posição (ver
/// `PriceAlertRule`) — dispara só na transição para a condição cumprida,
/// e rearma se o preço voltar para o outro lado do threshold.
List<AlertEvent> detectPriceThresholdCrossings({
  required List<PoolPosition> positions,
  required Map<String, PriceAlertRule> ruleByPositionKey,
}) {
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    if (position.isClosed) continue;
    final rule = ruleByPositionKey[position.positionKey];
    if (rule == null || !rule.enabled) continue;

    final met = priceThresholdMet(rule, position.currentTick);
    if (met && !rule.lastTriggered) {
      final directionLabel = rule.direction == PriceAlertDirection.above
          ? 'acima'
          : 'abaixo';
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.priceThreshold,
          title:
              '${position.token0Symbol}/${position.token1Symbol} — alerta de preço',
          body:
              'O preço acabou de ficar $directionLabel do teu threshold — '
              'independente do range desta posição.',
        ),
      );
    }
  }
  return alerts;
}

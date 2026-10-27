import '../../data/local/alert_state.dart';
import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/price_alert_rule.dart';
import '../../data/local/price_point.dart';
import 'portfolio_composition.dart';
import 'price_history_calc.dart';
import 'range_health.dart';

enum AlertKind {
  outOfRange,
  outOfRangeDuration,
  feeMilestone,
  feeSlowdown,
  feeSpike,
  priceThreshold,
  concentrationRisk,
}

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

/// Alerta para quem está fora do range há pelo menos [thresholdDays] dias
/// consecutivos — distinto de [detectRangeTransitions] (que dispara logo
/// ao sair, mesmo que só por minutos). [previousNotifiedByKey] marca quem
/// já foi avisado NESTE streak, para não reavisar a cada verificação
/// enquanto continuar fora — o chamador deve persistir o novo valor
/// (`duration != null && duration.inDays >= thresholdDays`) como o próximo
/// "já avisado", que naturalmente volta a `false` quando a posição regressa
/// ao range (a duração passa a `null`).
List<AlertEvent> detectOutOfRangeDuration({
  required List<PoolPosition> positions,
  required Map<String, List<PricePoint>> pricePointsByKey,
  required Map<String, bool> previousNotifiedByKey,
  required int thresholdDays,
  DateTime? now,
}) {
  if (thresholdDays <= 0) return [];
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    if (position.isClosed) continue;
    final duration = currentOutOfRangeDuration(
      points: pricePointsByKey[position.positionKey] ?? const [],
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
      now: now,
    );
    final exceeds = duration != null && duration.inDays >= thresholdDays;
    final alreadyNotified =
        previousNotifiedByKey[position.positionKey] ?? false;
    if (exceeds && !alreadyNotified) {
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.outOfRangeDuration,
          title:
              '${position.token0Symbol}/${position.token1Symbol} fora do range há ${duration.inDays}d',
          body:
              'Já leva ${duration.inDays} dias fora do range, sem gerar '
              'taxas novas — considera reequilibrar.',
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

/// `true` quando as fees das últimas 24h estão bem ACIMA da média diária
/// dos últimos 7 dias — o inverso de [isFeeSlowdown]: um dia excecional,
/// útil para o utilizador notar (pode ser um pico de volume temporário,
/// ou um sinal de que valeria a pena reequilibrar o range para captar
/// mais disto). Mesma condição de base de 7 dias suficiente para a
/// comparação fazer sentido.
bool isFeeSpike({
  required List<FeeSnapshot> snapshots,
  double spikeThresholdMultiplier = 2.0,
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
  return fees24h > avgDaily7d * spikeThresholdMultiplier;
}

/// Compara o estado de pico anterior com o atual e devolve um alerta só
/// para quem acabou de ENTRAR em pico — mesma lógica de "transição, não
/// estado" de [detectFeeSlowdowns].
List<AlertEvent> detectFeeSpikes({
  required List<PoolPosition> positions,
  required Map<String, List<FeeSnapshot>> snapshotsByKey,
  required Map<String, bool> previousSpikeByKey,
  DateTime? now,
}) {
  final alerts = <AlertEvent>[];
  for (final position in positions) {
    if (position.isClosed) continue;
    final snapshots = snapshotsByKey[position.positionKey] ?? const [];
    final spikeNow = isFeeSpike(snapshots: snapshots, now: now);
    final wasSpike = previousSpikeByKey[position.positionKey] ?? false;
    if (spikeNow && !wasSpike) {
      alerts.add(
        AlertEvent(
          positionKey: position.positionKey,
          kind: AlertKind.feeSpike,
          title:
              '${position.token0Symbol}/${position.token1Symbol} — pico de taxas',
          body:
              'As taxas das últimas 24h ficaram bem acima da média de 7 dias '
              'desta posição — dia de volume fora do normal.',
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

/// Maior fatia (por chain) da carteira, como % do valor total — `null`
/// sem posições abertas.
({String label, double pct})? biggestChainSlicePct(
  List<PoolPosition> positions,
) {
  final slices = compositionByChain(positions);
  final total = slices.fold<double>(0, (a, b) => a + b.valueUsd);
  if (slices.isEmpty || total <= 0) return null;
  final biggest = slices.reduce((a, b) => b.valueUsd > a.valueUsd ? b : a);
  return (label: biggest.label, pct: biggest.valueUsd / total * 100);
}

/// `true` quando uma única chain já passa [thresholdPct] do valor total da
/// carteira — sinal de concentração de risco.
bool isConcentrationRisk({
  required List<PoolPosition> positions,
  double thresholdPct = 60,
}) {
  final biggest = biggestChainSlicePct(positions);
  return biggest != null && biggest.pct >= thresholdPct;
}

/// Compara o estado de concentração anterior com o atual e devolve um
/// alerta só na transição para "em risco" — mesmo padrão de
/// [detectRangeTransitions]. É um alerta da CARTEIRA, não de uma posição
/// específica, por isso usa [portfolioAlertStateKey] como `positionKey`.
List<AlertEvent> detectConcentrationRisk({
  required List<PoolPosition> positions,
  required bool previouslyActive,
  double thresholdPct = 60,
}) {
  final biggest = biggestChainSlicePct(positions);
  if (biggest == null) return [];
  final isRiskNow = biggest.pct >= thresholdPct;
  if (!isRiskNow || previouslyActive) return [];
  return [
    AlertEvent(
      positionKey: portfolioAlertStateKey,
      kind: AlertKind.concentrationRisk,
      title: 'Concentração de risco alta',
      body:
          '${biggest.label} já representa ${biggest.pct.toStringAsFixed(0)}% '
          'do valor total da carteira — considera diversificar por mais chains.',
    ),
  ];
}

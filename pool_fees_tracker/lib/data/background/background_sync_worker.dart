import 'package:isar_community/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/calc/alert_detector.dart';
import '../../core/calc/dashboard_metrics.dart';
import '../../core/calc/price_history_calc.dart';
import '../../core/calc/range_health.dart';
import '../../core/calc/weekly_digest.dart';
import '../../core/format/currency_formatter.dart';
import '../local/alert_log_entry.dart';
import '../local/alert_state.dart';
import '../local/isar_service.dart';
import '../local/price_alert_rule.dart';
import '../local/settings_service.dart';
import '../repositories/isar_wallet_repository.dart';
import '../repositories/pool_fees_repository_factory.dart';
import '../services/home_widget_service.dart';
import '../services/notification_service.dart';

const backgroundSyncTaskName = 'pool_fees_tracker.background_sync';

/// Ponto de entrada que o Workmanager chama num isolate/processo em
/// background separado da app em primeiro plano — por isso não pode
/// assumir nada do estado em memória da app (providers, repositórios
/// vivos, etc.), só o que está persistido em disco (Isar, SharedPreferences).
///
/// Corre sempre (registada sem depender das definições de alertas), porque
/// também é o único sítio que mantém o widget de ecrã inicial atualizado
/// com a app fechada.
@pragma('vm:entry-point')
void backgroundSyncCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await runBackgroundSync();
    } catch (_) {
      // Uma execução em background nunca deve rebentar a task — a
      // próxima execução periódica tenta de novo.
    }
    return true;
  });
}

/// Atualiza o widget de ecrã inicial e, se os alertas estiverem ligados,
/// verifica e dispara notificações. Extraída à parte do dispatcher para
/// poder ser chamada também em primeiro plano (o botão "Check now" do
/// ecrã de Alerts), sem depender do Workmanager.
///
/// Devolve o número de alertas disparados nesta execução.
Future<int> runBackgroundSync() async {
  final isar = await IsarService.open();
  final settingsService = await SettingsService.create();
  final settings = settingsService.load();

  final walletRepository = IsarWalletRepository(isar);
  final repo = createPoolFeesRepository(
    settings: settings,
    walletRepository: walletRepository,
    isar: isar,
  );

  try {
    // `refreshNow()` agora espera mesmo pelo refresh (ver nota em
    // `LivePoolFeesRepository.refreshNow`) — sem isto, `watchPositions()
    // .first` apanhava quase sempre o valor ANTIGO (cache ou vazio),
    // porque o construtor do repositório já tinha disparado o seu
    // próprio refresh em paralelo e não havia garantia de esperar por
    // ele. Era a causa mais provável de os alertas parecerem não
    // disparar: a verificação corria sobre dados desatualizados.
    await repo.refreshNow().timeout(
      const Duration(seconds: 30),
      onTimeout: () {},
    );
    final positions = await repo.watchPositions().first;

    final snapshotsByKey = {
      for (final position in positions)
        position.positionKey: await repo.getFeeSnapshots(position.positionKey),
    };
    final metrics = computeDashboardMetrics(
      positions: positions,
      snapshotsByKey: snapshotsByKey,
    );
    final widgetFormatter = CurrencyFormatter(settings.currencyCode);
    final widgetValue = widgetMetricValueUsd(settings.widgetMetric, metrics);
    final widgetSecondaries = secondaryWidgetMetrics(settings.widgetMetric);
    await HomeWidgetService.update(
      titleLabel: settings.widgetMetric.widgetTitle,
      valueFormatted: widgetFormatter.format(widgetValue),
      updatedAtLabel: 'Atualizado agora mesmo',
      secondary1Label: widgetSecondaries[0].widgetTitle,
      secondary1Value: widgetFormatter.format(
        widgetMetricValueUsd(widgetSecondaries[0], metrics),
      ),
      secondary2Label: widgetSecondaries[1].widgetTitle,
      secondary2Value: widgetFormatter.format(
        widgetMetricValueUsd(widgetSecondaries[1], metrics),
      ),
    );

    if (!settings.alertsEnabled) return 0;

    final pricePointsByKey = {
      for (final position in positions)
        position.positionKey: await repo.getPricePoints(position.positionKey),
    };
    final previousStates = await isar.alertStates.where().findAll();
    final previousStatusByKey = {
      for (final s in previousStates) s.positionKey: s.lastRangeStatus,
    };
    final lastNotifiedFeesByKey = {
      for (final s in previousStates) s.positionKey: s.lastNotifiedFeesTotal,
    };
    final previousSlowdownByKey = {
      for (final s in previousStates) s.positionKey: s.lastFeeSlowdownNotified,
    };
    final previousOutOfRangeDurationByKey = {
      for (final s in previousStates)
        s.positionKey: s.lastOutOfRangeDurationNotified,
    };
    bool previousConcentrationActive = false;
    DateTime? previousWeeklyDigestSentAt;
    for (final s in previousStates) {
      if (s.positionKey == portfolioAlertStateKey) {
        previousConcentrationActive = s.lastConcentrationRiskActive;
        previousWeeklyDigestSentAt = s.lastWeeklyDigestSentAt;
        break;
      }
    }
    final priceAlertRules = await isar.priceAlertRules.where().findAll();
    final ruleByPositionKey = {
      for (final rule in priceAlertRules) rule.positionKey: rule,
    };

    final rangeAlerts = settings.outOfRangeAlertsEnabled
        ? detectRangeTransitions(
            positions: positions,
            previousStatusByKey: previousStatusByKey,
          )
        : <AlertEvent>[];
    final outOfRangeDurationAlerts = settings.outOfRangeDurationAlertsEnabled
        ? detectOutOfRangeDuration(
            positions: positions,
            pricePointsByKey: pricePointsByKey,
            previousNotifiedByKey: previousOutOfRangeDurationByKey,
            thresholdDays: settings.outOfRangeDurationThresholdDays,
          )
        : <AlertEvent>[];
    final milestoneAlerts = settings.feeMilestoneAlertsEnabled
        ? detectFeeMilestones(
            positions: positions,
            lastNotifiedFeesByKey: lastNotifiedFeesByKey,
            thresholdUsd: settings.feeMilestoneThresholdUsd,
          )
        : <AlertEvent>[];
    final slowdownAlerts = settings.feeSlowdownAlertsEnabled
        ? detectFeeSlowdowns(
            positions: positions,
            snapshotsByKey: snapshotsByKey,
            previousSlowdownByKey: previousSlowdownByKey,
          )
        : <AlertEvent>[];
    final priceThresholdAlerts = detectPriceThresholdCrossings(
      positions: positions,
      ruleByPositionKey: ruleByPositionKey,
    );
    final concentrationAlerts = settings.concentrationRiskAlertsEnabled
        ? detectConcentrationRisk(
            positions: positions,
            previouslyActive: previousConcentrationActive,
          )
        : <AlertEvent>[];
    final allAlerts = [
      ...rangeAlerts,
      ...outOfRangeDurationAlerts,
      ...milestoneAlerts,
      ...slowdownAlerts,
      ...priceThresholdAlerts,
      ...concentrationAlerts,
    ];

    for (final alert in allAlerts) {
      await NotificationService.instance.show(
        id: alert.positionKey.hashCode & 0x7fffffff,
        title: alert.title,
        body: alert.body,
      );
    }

    var weeklyDigestSentAt = previousWeeklyDigestSentAt;
    if (settings.weeklyDigestEnabled &&
        shouldSendWeeklyDigest(lastSentAt: previousWeeklyDigestSentAt)) {
      final digest = computeWeeklyDigest(
        positions: positions,
        snapshotsByKey: snapshotsByKey,
      );
      await NotificationService.instance.show(
        id: 'weekly_digest'.hashCode & 0x7fffffff,
        title: 'Resumo semanal',
        body: buildWeeklyDigestBody(
          digest,
          CurrencyFormatter(settings.currencyCode),
        ),
      );
      weeklyDigestSentAt = DateTime.now();
    }

    await isar.writeTxn(() async {
      for (final position in positions) {
        final health = computeRangeHealth(
          tickLower: position.tickLower,
          tickUpper: position.tickUpper,
          currentTick: position.currentTick,
        );
        double notifiedFeesTotal =
            lastNotifiedFeesByKey[position.positionKey] ?? 0;
        for (final milestone in milestoneAlerts) {
          if (milestone.positionKey == position.positionKey) {
            notifiedFeesTotal =
                milestone.newNotifiedFeesTotal ?? notifiedFeesTotal;
          }
        }
        final slowdownNow = isFeeSlowdown(
          snapshots: snapshotsByKey[position.positionKey] ?? const [],
        );
        final outOfRangeDurationNow =
            (currentOutOfRangeDuration(
                  points: pricePointsByKey[position.positionKey] ?? const [],
                  tickLower: position.tickLower,
                  tickUpper: position.tickUpper,
                )?.inDays ??
                -1) >=
            settings.outOfRangeDurationThresholdDays;

        await isar.alertStates.put(
          AlertState()
            ..positionKey = position.positionKey
            ..lastRangeStatus = health.status
            ..lastNotifiedFeesTotal = notifiedFeesTotal
            ..lastFeeSlowdownNotified = slowdownNow
            ..lastOutOfRangeDurationNotified = outOfRangeDurationNow,
        );

        final rule = ruleByPositionKey[position.positionKey];
        if (rule != null) {
          await isar.priceAlertRules.put(
            rule..lastTriggered = priceThresholdMet(rule, position.currentTick),
          );
        }
      }

      await isar.alertStates.put(
        AlertState()
          ..positionKey = portfolioAlertStateKey
          ..lastRangeStatus = RangeStatus.inRange
          ..lastNotifiedFeesTotal = 0
          ..lastConcentrationRiskActive = isConcentrationRisk(
            positions: positions,
          )
          ..lastWeeklyDigestSentAt = weeklyDigestSentAt,
      );

      for (final alert in allAlerts) {
        await isar.alertLogEntrys.put(
          AlertLogEntry()
            ..positionKey = alert.positionKey
            ..kind = switch (alert.kind) {
              AlertKind.outOfRange => AlertLogKind.outOfRange,
              AlertKind.outOfRangeDuration => AlertLogKind.outOfRangeDuration,
              AlertKind.feeMilestone => AlertLogKind.feeMilestone,
              AlertKind.feeSlowdown => AlertLogKind.feeSlowdown,
              AlertKind.priceThreshold => AlertLogKind.priceThreshold,
              AlertKind.concentrationRisk => AlertLogKind.concentrationRisk,
            }
            ..title = alert.title
            ..body = alert.body
            ..firedAt = DateTime.now(),
        );
      }
    });

    return allAlerts.length;
  } finally {
    repo.dispose();
  }
}

import 'package:isar_community/isar.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/calc/alert_detector.dart';
import '../../core/calc/range_health.dart';
import '../../core/format/currency_formatter.dart';
import '../local/alert_log_entry.dart';
import '../local/alert_state.dart';
import '../local/isar_service.dart';
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
    final positions = await repo.watchPositions().first.timeout(
      const Duration(seconds: 30),
    );

    final totalFeesUsd = positions.fold<double>(
      0,
      (sum, position) => sum + position.feesTotalUsd,
    );
    await HomeWidgetService.update(
      totalFeesFormatted: CurrencyFormatter(settings.currencyCode)
          .format(totalFeesUsd),
      updatedAtLabel: 'Updated just now',
    );

    if (!settings.alertsEnabled) return 0;

    final previousStates = await isar.alertStates.where().findAll();
    final previousStatusByKey = {
      for (final s in previousStates) s.positionKey: s.lastRangeStatus,
    };
    final lastNotifiedFeesByKey = {
      for (final s in previousStates) s.positionKey: s.lastNotifiedFeesTotal,
    };

    final rangeAlerts = settings.outOfRangeAlertsEnabled
        ? detectRangeTransitions(
            positions: positions,
            previousStatusByKey: previousStatusByKey,
          )
        : <AlertEvent>[];
    final milestoneAlerts = settings.feeMilestoneAlertsEnabled
        ? detectFeeMilestones(
            positions: positions,
            lastNotifiedFeesByKey: lastNotifiedFeesByKey,
            thresholdUsd: settings.feeMilestoneThresholdUsd,
          )
        : <AlertEvent>[];
    final allAlerts = [...rangeAlerts, ...milestoneAlerts];

    for (final alert in allAlerts) {
      await NotificationService.instance.show(
        id: alert.positionKey.hashCode & 0x7fffffff,
        title: alert.title,
        body: alert.body,
      );
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

        await isar.alertStates.put(
          AlertState()
            ..positionKey = position.positionKey
            ..lastRangeStatus = health.status
            ..lastNotifiedFeesTotal = notifiedFeesTotal,
        );
      }

      for (final alert in allAlerts) {
        await isar.alertLogEntrys.put(
          AlertLogEntry()
            ..positionKey = alert.positionKey
            ..kind = alert.kind == AlertKind.outOfRange
                ? AlertLogKind.outOfRange
                : AlertLogKind.feeMilestone
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

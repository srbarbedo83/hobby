import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'core/providers.dart';
import 'data/background/background_sync_worker.dart';
import 'data/local/isar_service.dart';
import 'data/local/settings_service.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US');
  final isar = await IsarService.open();
  final settingsService = await SettingsService.create();

  await NotificationService.instance.init();
  // Regista sempre (não só quando os alertas estão ligados): esta task
  // também é o que mantém o widget de ecrã inicial atualizado com a app
  // fechada. Registar de novo com o mesmo nome único é idempotente
  // (atualiza a task em vez de duplicar).
  await Workmanager().initialize(backgroundSyncCallbackDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: const Duration(minutes: 15),
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const PoolFeesTrackerApp(),
    ),
  );
}

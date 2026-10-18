import 'dart:async';

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

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const PoolFeesTrackerApp(),
    ),
  );

  // Fora do caminho crítico do primeiro frame — notificações e o registo do
  // Workmanager não são precisos para mostrar a UI, e uma falha ou demora
  // aqui (ex.: diálogo de permissão, handshake do WorkManager) nunca deve
  // deixar a app presa no splash screen.
  unawaited(_initBackgroundServices());
}

Future<void> _initBackgroundServices() async {
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Alertas locais ficam indisponíveis, mas a app continua a funcionar.
  }
  try {
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
  } catch (_) {
    // Atualização em background indisponível, mas a app em primeiro plano
    // continua a funcionar normalmente.
  }
}

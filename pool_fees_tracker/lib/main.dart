import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/providers.dart';
import 'data/local/isar_service.dart';
import 'data/local/settings_service.dart';

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
}

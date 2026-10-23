import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/calc/dashboard_metrics.dart';
import '../core/format/currency_formatter.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../data/local/settings_service.dart';
import '../data/services/home_widget_service.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/pools/pools_screen.dart';
import '../features/settings/settings_screen.dart';

extension on AppThemeMode {
  ThemeMode get flutterThemeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    // Flutter só tem claro/escuro — "extra escuro" é só outra ThemeData
    // escolhida à parte (ver `darkTheme:` abaixo), não um ThemeMode novo.
    AppThemeMode.extraDark => ThemeMode.dark,
  };
}

class PoolFeesTrackerApp extends ConsumerWidget {
  const PoolFeesTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appSettingsProvider).themeMode;
    final isExtraDark = themeMode == AppThemeMode.extraDark;
    return MaterialApp(
      title: 'Pool Fees Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: isExtraDark ? AppTheme.extraDark() : AppTheme.dark(),
      themeMode: themeMode.flutterThemeMode,
      // `AppPalette.extraDark().background` é transparente de propósito —
      // o degradê real só existe aqui, pintado uma única vez por trás de
      // toda a app (Dashboard, Pools, Definições e o ecrã de detalhe da
      // pool, que é outra rota empilhada por cima), em vez de em cada
      // Scaffold individual.
      builder: (context, child) => isExtraDark
          ? DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppPalette.extraDarkBackgroundGradient,
              ),
              child: child,
            )
          : child ?? const SizedBox.shrink(),
      home: const _RootNavigation(),
    );
  }
}

class _RootNavigation extends ConsumerStatefulWidget {
  const _RootNavigation();

  @override
  ConsumerState<_RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends ConsumerState<_RootNavigation> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    PoolsScreen(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  void _updateWidget() {
    final positions = ref.read(positionsStreamProvider).value;
    if (positions == null) return;
    final snapshots = ref.read(allFeeSnapshotsProvider).value ?? const {};
    final metrics = computeDashboardMetrics(
      positions: positions,
      snapshotsByKey: snapshots,
    );
    final settings = ref.read(appSettingsProvider);
    final value = widgetMetricValueUsd(settings.widgetMetric, metrics);
    HomeWidgetService.update(
      titleLabel: settings.widgetMetric.widgetTitle,
      valueFormatted: CurrencyFormatter(settings.currencyCode).format(value),
      updatedAtLabel: 'Atualizado agora mesmo',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mantém o widget de ecrã inicial atualizado enquanto a app está
    // aberta (em background, só a sincronização periódica do Workmanager
    // o faz — ver background_sync_worker.dart). Ouve as duas fontes: a
    // lista de posições (muda a cada tick live) e o histórico de
    // snapshots (resolve de forma assíncrona, pode chegar depois) —
    // "24h fees" só fica certo quando ambas já carregaram.
    ref.listen(positionsStreamProvider, (previous, next) => _updateWidget());
    ref.listen(allFeeSnapshotsProvider, (previous, next) => _updateWidget());

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Pools',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Definições',
          ),
        ],
      ),
    );
  }
}

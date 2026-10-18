import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format/currency_formatter.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../data/services/home_widget_service.dart';
import '../features/alerts/alerts_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/pools/pools_screen.dart';
import '../features/settings/settings_screen.dart';

class PoolFeesTrackerApp extends StatelessWidget {
  const PoolFeesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool Fees Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
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

  @override
  Widget build(BuildContext context) {
    // Mantém o widget de ecrã inicial atualizado enquanto a app está
    // aberta (em background, só a sincronização periódica do Workmanager
    // o faz — ver background_sync_worker.dart).
    ref.listen(positionsStreamProvider, (previous, next) {
      final positions = next.value;
      if (positions == null) return;
      final total = positions.fold<double>(
        0,
        (sum, position) => sum + position.feesTotalUsd,
      );
      final currencyCode = ref.read(appSettingsProvider).currencyCode;
      HomeWidgetService.update(
        totalFeesFormatted: CurrencyFormatter(currencyCode).format(total),
        updatedAtLabel: 'Updated just now',
      );
    });

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
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

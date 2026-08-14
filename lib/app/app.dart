import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/adherence/adherence_screen.dart';
import '../features/hobbies/hobby_list_screen.dart';
import '../features/overview/overview_screen.dart';

class RitmoApp extends StatelessWidget {
  const RitmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _RaizNavegacao(),
    );
  }
}

class _RaizNavegacao extends StatefulWidget {
  const _RaizNavegacao();

  @override
  State<_RaizNavegacao> createState() => _RaizNavegacaoState();
}

class _RaizNavegacaoState extends State<_RaizNavegacao> {
  int _indice = 0;

  static const _ecras = [HobbyListScreen(), AdherenceScreen(), OverviewScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _ecras),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) => setState(() => _indice = indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Hobbies',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Assiduidade',
          ),
          NavigationDestination(
            icon: Icon(Icons.stacked_line_chart_outlined),
            selectedIcon: Icon(Icons.stacked_line_chart),
            label: 'Resumo',
          ),
        ],
      ),
    );
  }
}

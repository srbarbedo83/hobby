import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/hobby.dart';
import '../../data/local/sessao_registada.dart';
import '../hobbies/hobby_providers.dart';
import '../hobby_detail/hobby_detail_providers.dart';
import 'evolucao_todos_hobbies_chart.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbiesAsync = ref.watch(hobbiesAtivosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo')),
      body: hobbiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro a carregar hobbies: $err')),
        data: (hobbies) {
          if (hobbies.isEmpty) {
            return const _SemHobbies();
          }
          return _Evolucao(hobbies: hobbies);
        },
      ),
    );
  }
}

class _SemHobbies extends StatelessWidget {
  const _SemHobbies();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stacked_line_chart_outlined,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text(
              'Ainda não tens hobbies para comparar.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Junta as sessões de todos os hobbies antes de desenhar o gráfico — cada
/// hobby tem o seu próprio stream, por isso observam-se todos aqui e só se
/// avança quando todos já tiverem dados.
class _Evolucao extends ConsumerWidget {
  const _Evolucao({required this.hobbies});

  final List<Hobby> hobbies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final porHobby = <Hobby, List<SessaoRegistada>>{};
    for (final hobby in hobbies) {
      final sessoes = ref.watch(sessoesPorHobbyProvider(hobby.id)).value;
      if (sessoes == null) {
        return const Center(child: CircularProgressIndicator());
      }
      porHobby[hobby] = sessoes;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Evolução semanal', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        EvolucaoTodosHobbiesChart(porHobby: porHobby),
      ],
    );
  }
}

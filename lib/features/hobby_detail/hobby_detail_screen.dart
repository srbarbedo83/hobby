import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/duration_formatter.dart';
import '../hobbies/hobby_form_screen.dart';
import '../hobbies/hobby_providers.dart';
import 'heatmap_calendario.dart';
import 'hobby_detail_providers.dart';
import 'hobby_stats.dart';

class HobbyDetailScreen extends ConsumerWidget {
  const HobbyDetailScreen({super.key, required this.hobbyId});

  final int hobbyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbyAsync = ref.watch(hobbyByIdProvider(hobbyId));

    return Scaffold(
      appBar: AppBar(
        title: Text(hobbyAsync.value?.nome ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar hobby',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HobbyFormScreen(hobbyId: hobbyId)),
            ),
          ),
        ],
      ),
      body: hobbyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro a carregar hobby: $err')),
        data: (hobby) {
          if (hobby == null) {
            return const Center(child: Text('Hobby não encontrado.'));
          }
          final cor = Color(hobby.cor);
          final sessoesAsync = ref.watch(sessoesPorHobbyProvider(hobbyId));

          return sessoesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro a carregar sessões: $err')),
            data: (sessoes) {
              final stats = HobbyStats.calcular(sessoes);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Últimas ${HeatmapCalendario.semanasPredefinidas} semanas',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  HeatmapCalendario(sessoes: sessoes, cor: cor),
                  const SizedBox(height: 28),
                  Text('Estatísticas', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _EstatisticasGrid(stats: stats, cor: cor),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _EstatisticasGrid extends StatelessWidget {
  const _EstatisticasGrid({required this.stats, required this.cor});

  final HobbyStats stats;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _StatCard(rotulo: 'Total acumulado', valor: formatarDuracao(stats.totalSegundos), cor: cor),
        _StatCard(rotulo: 'Média por semana', valor: formatarDuracao(stats.mediaSemanalSegundos), cor: cor),
        _StatCard(rotulo: 'Sessão mais longa', valor: formatarDuracao(stats.sessaoMaisLongaSegundos), cor: cor),
        _StatCard(rotulo: 'Nº de sessões', valor: '${stats.numeroSessoes}', cor: cor),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.rotulo, required this.valor, required this.cor});

  final String rotulo;
  final String valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: cor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rotulo,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

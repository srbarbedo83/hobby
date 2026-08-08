import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/duration_formatter.dart';
import '../../data/local/hobby.dart';
import '../hobbies/hobby_providers.dart';
import '../hobby_detail/hobby_detail_providers.dart';
import 'assiduidade_calculator.dart';

class AdherenceScreen extends ConsumerWidget {
  const AdherenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbiesAsync = ref.watch(hobbiesAtivosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assiduidade')),
      body: hobbiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro a carregar hobbies: $err')),
        data: (hobbies) {
          final comMeta = hobbies.where((h) => h.meta != null).toList();
          if (comMeta.isEmpty) {
            return const _SemMetas();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: comMeta.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AdherenceTile(hobby: comMeta[index]),
          );
        },
      ),
    );
  }
}

class _SemMetas extends StatelessWidget {
  const _SemMetas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text(
              'Nenhum hobby tem uma meta definida.\nEdita um hobby para lhe atribuir uma.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdherenceTile extends ConsumerWidget {
  const _AdherenceTile({required this.hobby});

  final Hobby hobby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessoesAsync = ref.watch(sessoesPorHobbyProvider(hobby.id));
    final cor = Color(hobby.cor);

    return sessoesAsync.when(
      loading: () => const SizedBox(height: 72, child: Center(child: CircularProgressIndicator())),
      error: (err, _) => Text('Erro: $err'),
      data: (sessoes) {
        final assiduidade = calcularAssiduidade(hobby, sessoes);
        if (assiduidade == null) return const SizedBox.shrink();

        final progresso = (assiduidade.percentagem / 100).clamp(0.0, 1.0);
        final excedente =
            assiduidade.percentagem > 100 ? assiduidade.percentagem.round() - 100 : null;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(hobby.nome, style: Theme.of(context).textTheme.titleMedium)),
                  Text(
                    '${assiduidade.percentagem.round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                  if (excedente != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '+$excedente%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progresso,
                  minHeight: 8,
                  backgroundColor: cor.withValues(alpha: 0.15),
                  color: cor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_formatarRealizadoAlvo(assiduidade)} — ${_rotuloPeriodo(assiduidade.periodo)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatarRealizadoAlvo(Assiduidade a) {
  if (a.unidade == UnidadeMeta.tempo) {
    return '${formatarDuracao(a.realizado)} de ${formatarDuracao(a.alvo)}';
  }
  return '${a.realizado} de ${a.alvo} sessões';
}

String _rotuloPeriodo(PeriodoAssiduidade periodo) {
  return periodo == PeriodoAssiduidade.semana ? 'esta semana' : 'hoje';
}

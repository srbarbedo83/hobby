import 'package:flutter/material.dart';

import 'nivel_mestria.dart';

class NivelMestriaCard extends StatelessWidget {
  const NivelMestriaCard({super.key, required this.totalSegundos, required this.cor});

  final int totalSegundos;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final nivel = calcularNivelMestria(totalSegundos);
    final proximo = nivel.proximoPatamar;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech_outlined, color: cor, size: 20),
              const SizedBox(width: 8),
              Text(
                nivel.patamarAtual.nome,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: nivel.progresso,
              minHeight: 8,
              backgroundColor: cor.withValues(alpha: 0.15),
              color: cor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            proximo == null
                ? '${nivel.horasAtuais.round()}h — nível máximo desta escala atingido'
                : 'Faltam ${nivel.horasEmFalta.round()}h para "${proximo.nome}" (${proximo.horas}h)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            'Escala aproximada, só para motivar — não é uma medida oficial.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

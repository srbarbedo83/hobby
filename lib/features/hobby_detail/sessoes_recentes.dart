import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format/duration_formatter.dart';
import '../../data/local/sessao_registada.dart';

/// Últimas sessões de um hobby, mais recente primeiro — é onde a nota
/// opcional de cada sessão fica visível depois de escrita.
class SessoesRecentes extends StatelessWidget {
  const SessoesRecentes({super.key, required this.sessoes, required this.cor, this.limite = 10});

  /// Ordenadas por [SessaoRegistada.inicio] ascendente (tal como chegam do repositório).
  final List<SessaoRegistada> sessoes;
  final Color cor;
  final int limite;

  @override
  Widget build(BuildContext context) {
    if (sessoes.isEmpty) {
      return Text(
        'Ainda não há sessões registadas.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    final recentes = sessoes.reversed.take(limite).toList();
    return Column(
      children: [
        for (final sessao in recentes) _LinhaSessao(sessao: sessao, cor: cor),
      ],
    );
  }
}

class _LinhaSessao extends StatelessWidget {
  const _LinhaSessao({required this.sessao, required this.cor});

  final SessaoRegistada sessao;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            sessao.origem == OrigemSessao.cronometro ? Icons.timer_outlined : Icons.edit_note,
            size: 18,
            color: cor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(DateFormat('d MMM', 'pt_PT').format(sessao.inicio)),
                    const SizedBox(width: 8),
                    Text(
                      formatarDuracao(sessao.duracaoSegundos),
                      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
                if (sessao.nota != null && sessao.nota!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      sessao.nota!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/format/duration_formatter.dart';
import '../../data/local/sessao_registada.dart';

/// Grelha tipo "contribuições" mas com intensidade proporcional ao TEMPO
/// investido nesse dia (não um simples sim/não) — é a distinção central da
/// app face a trackers de hábitos binários.
class HeatmapCalendario extends StatelessWidget {
  const HeatmapCalendario({
    super.key,
    required this.sessoes,
    required this.cor,
    this.semanas = semanasPredefinidas,
  });

  static const semanasPredefinidas = 18;

  final List<SessaoRegistada> sessoes;
  final Color cor;
  final int semanas;

  @override
  Widget build(BuildContext context) {
    final porDia = _agruparPorDia(sessoes);
    final hoje = _apenasData(DateTime.now());
    final inicioSemanaAtual = hoje.subtract(Duration(days: hoje.weekday - 1));
    final inicioGrelha = inicioSemanaAtual.subtract(Duration(days: 7 * (semanas - 1)));

    final maxSegundos = porDia.values.isEmpty
        ? 0
        : porDia.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(semanas, (semanaIndex) {
          final inicioSemana = inicioGrelha.add(Duration(days: 7 * semanaIndex));
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Column(
              children: List.generate(7, (diaIndex) {
                final dia = inicioSemana.add(Duration(days: diaIndex));
                final futuro = dia.isAfter(hoje);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: _CelulaHeatmap(
                    dia: dia,
                    segundos: futuro ? null : (porDia[dia] ?? 0),
                    maxSegundos: maxSegundos,
                    cor: cor,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _CelulaHeatmap extends StatelessWidget {
  const _CelulaHeatmap({
    required this.dia,
    required this.segundos,
    required this.maxSegundos,
    required this.cor,
  });

  final DateTime dia;

  /// `null` para dias no futuro, que não devem ser desenhados.
  final int? segundos;
  final int maxSegundos;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final valor = segundos;
    if (valor == null) {
      return const SizedBox(width: 14, height: 14);
    }

    final nivel = _nivel(valor, maxSegundos);
    final corCelula = nivel == 0
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : cor.withValues(alpha: 0.2 + 0.2 * nivel);

    final rotulo = valor > 0 ? formatarDuracao(valor) : 'sem sessões';
    return Tooltip(
      message: '${DateFormat('d MMM', 'pt_PT').format(dia)} — $rotulo',
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: corCelula, borderRadius: BorderRadius.circular(3)),
      ),
    );
  }

  static int _nivel(int segundos, int maxSegundos) {
    if (segundos <= 0 || maxSegundos <= 0) return 0;
    final proporcao = segundos / maxSegundos;
    if (proporcao >= 0.75) return 4;
    if (proporcao >= 0.5) return 3;
    if (proporcao >= 0.25) return 2;
    return 1;
  }
}

Map<DateTime, int> _agruparPorDia(List<SessaoRegistada> sessoes) {
  final mapa = <DateTime, int>{};
  for (final sessao in sessoes) {
    final dia = _apenasData(sessao.inicio);
    mapa[dia] = (mapa[dia] ?? 0) + sessao.duracaoSegundos;
  }
  return mapa;
}

DateTime _apenasData(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

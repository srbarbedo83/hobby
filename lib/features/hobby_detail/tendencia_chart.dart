import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'tendencia_semanal.dart';

/// Linha sólida com o tempo semanal real, seguida de uma linha tracejada
/// com uma projeção simples a partir do ritmo recente — não é uma previsão
/// a sério, só uma extrapolação do momentum das últimas semanas.
class TendenciaChart extends StatelessWidget {
  const TendenciaChart({super.key, required this.pontos, required this.cor});

  final List<PontoSemanal> pontos;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    if (pontos.isEmpty) return const SizedBox.shrink();

    final historico = pontos.where((p) => !p.projetado).toList();
    final ultimoIndiceHistorico = historico.length - 1;

    final spotsHistorico = [
      for (var i = 0; i < historico.length; i++) FlSpot(i.toDouble(), historico[i].minutos),
    ];
    final spotsProjecao = [
      FlSpot(ultimoIndiceHistorico.toDouble(), historico.last.minutos),
      for (var i = historico.length; i < pontos.length; i++)
        FlSpot(i.toDouble(), pontos[i].minutos),
    ];

    final maxMinutos = pontos.map((p) => p.minutos).fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxMinutos <= 0 ? 60.0 : maxMinutos * 1.25;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).colorScheme.outlineVariant,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  '${(value / 60).toStringAsFixed(0)}h',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final indice = value.round();
                  if (indice < 0 || indice >= pontos.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('d/M', 'pt_PT').format(pontos[indice].inicioSemana),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spotsHistorico,
              isCurved: false,
              color: cor,
              barWidth: 2.5,
              dotData: const FlDotData(),
            ),
            LineChartBarData(
              spots: spotsProjecao,
              isCurved: false,
              color: cor.withValues(alpha: 0.55),
              barWidth: 2,
              dashArray: const [6, 4],
              dotData: const FlDotData(),
            ),
          ],
        ),
      ),
    );
  }
}

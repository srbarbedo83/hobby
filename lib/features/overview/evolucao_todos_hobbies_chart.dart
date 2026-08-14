import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/local/hobby.dart';
import '../../data/local/sessao_registada.dart';
import '../hobby_detail/tendencia_semanal.dart';

/// Uma linha por hobby (na cor do próprio hobby), para comparar a
/// evolução semanal de todos ao mesmo tempo — não é uma métrica nova,
/// reaproveita a mesma agregação semanal do gráfico de tendência
/// individual, só sem a parte de projeção.
class EvolucaoTodosHobbiesChart extends StatelessWidget {
  const EvolucaoTodosHobbiesChart({super.key, required this.porHobby, this.semanas = 8});

  final Map<Hobby, List<SessaoRegistada>> porHobby;
  final int semanas;

  @override
  Widget build(BuildContext context) {
    final series = <Hobby, List<PontoSemanal>>{
      for (final entry in porHobby.entries)
        entry.key: calcularTendenciaSemanal(
          entry.value,
          semanasHistorico: semanas,
          semanasProjecao: 0,
        ),
    };

    final maxMinutos = series.values
        .expand((pontos) => pontos)
        .map((p) => p.minutos)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxMinutos <= 0 ? 60.0 : maxMinutos * 1.25;

    final referencia = series.values.firstOrNull ?? const <PontoSemanal>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
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
                      if (indice < 0 || indice >= referencia.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('d/M', 'pt_PT').format(referencia[indice].inicioSemana),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                for (final entry in series.entries)
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < entry.value.length; i++)
                        FlSpot(i.toDouble(), entry.value[i].minutos),
                    ],
                    isCurved: false,
                    color: Color(entry.key.cor),
                    barWidth: 2.5,
                    dotData: const FlDotData(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final hobby in porHobby.keys)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: Color(hobby.cor), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(hobby.nome, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

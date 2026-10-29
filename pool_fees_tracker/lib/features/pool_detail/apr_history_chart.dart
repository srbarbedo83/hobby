import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/apr_history.dart';
import '../../core/theme/app_theme.dart';

/// Linha da APR realizada implícita em cada barra ao longo do tempo — mostra
/// se o retorno da posição está a acelerar ou a abrandar, em vez de só a
/// média de 7 dias que o resto do ecrã usa.
class AprHistoryChart extends StatelessWidget {
  final List<AprPoint> points;
  final Color accentColor;

  const AprHistoryChart({
    super.key,
    required this.points,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (points.length < 2) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Ainda sem histórico suficiente para a APR ao longo do tempo',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
      );
    }

    final values = points.map((p) => p.aprPct).toList();
    final dataMin = values.reduce((a, b) => a < b ? a : b);
    final dataMax = values.reduce((a, b) => a > b ? a : b);
    final pad = (dataMax - dataMin) * 0.1 + (dataMax - dataMin == 0 ? 1 : 0);
    // O chão só é forçado a 0 quando os dados já são todos ≥ 0 (o caso
    // normal) — se alguma barra for negativa, limitar minY a 0 punha-o
    // ACIMA do maxY (que já ficava negativo), invertendo o eixo e
    // fazendo a linha atravessar o gráfico todo de forma disparatada.
    final chartMinY = dataMin >= 0
        ? (dataMin - pad).clamp(0, double.infinity).toDouble()
        : dataMin - pad;
    final chartMaxY = dataMax + pad;

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: chartMinY,
          maxY: chartMaxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            // Pedido do utilizador: faltava escala no eixo da APR.
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: (chartMaxY - chartMinY) / 2,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${value.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 9,
                        color: palette.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: (points.length / 4)
                    .clamp(1, points.length)
                    .toDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.round();
                  if (idx < 0 || idx >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      points[idx].label,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              color: accentColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

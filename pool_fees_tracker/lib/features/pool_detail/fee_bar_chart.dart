import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/theme/app_theme.dart';

/// Gráfico de barras das fees geradas, agregadas por [BarPoint]. Tocar numa
/// barra chama [onBarSelected] com o seu índice (ou `null` ao largar o
/// toque), para o ecrã mostrar o valor exato dessa barra por baixo.
class FeeBarChart extends StatelessWidget {
  final List<BarPoint> bars;
  final int? selectedIndex;
  final Color accentColor;
  final ValueChanged<int?> onBarSelected;

  const FeeBarChart({
    super.key,
    required this.bars,
    required this.selectedIndex,
    required this.accentColor,
    required this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (bars.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No fee history yet',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
      );
    }

    final maxValue = bars
        .map((b) => b.valueUsd)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
            ),
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response?.spot == null) {
                return;
              }
              onBarSelected(response!.spot!.touchedBarGroupIndex);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= bars.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      bars[idx].label,
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
          barGroups: [
            for (var i = 0; i < bars.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: bars[i].valueUsd,
                    width: 18,
                    color: i == selectedIndex
                        ? accentColor
                        : palette.textSecondary.withValues(alpha: 0.25),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                      bottom: Radius.circular(2),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/theme/app_theme.dart';

/// Gráfico de barras das fees geradas, agregadas por [BarPoint]. Tocar numa
/// barra chama [onBarSelected] com o seu índice (ou `null` ao largar o
/// toque), para o ecrã mostrar o valor exato dessa barra por baixo.
class FeeBarChart extends StatelessWidget {
  final List<BarPoint> bars;
  final int? selectedIndex;
  final Color accentColor;
  final ValueChanged<int?> onBarSelected;
  final CurrencyFormatter formatter;

  const FeeBarChart({
    super.key,
    required this.bars,
    required this.selectedIndex,
    required this.accentColor,
    required this.onBarSelected,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (bars.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'Ainda sem histórico de taxas',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
      );
    }

    final maxValue = bars
        .map((b) => b.valueUsd)
        .fold<double>(0, (a, b) => a > b ? a : b);
    // Normalmente os deltas de fees nunca são negativos (ver nota em
    // `live_pool_fees_repository.dart`), mas um minY fixo em 0 fazia a
    // barra sair do gráfico para baixo sempre que algum valor antigo já
    // gravado no telefone (antes desse fix) fosse negativo — por isso o
    // chão do eixo acompanha o valor mínimo real em vez de assumir 0.
    final minValue = bars
        .map((b) => b.valueUsd)
        .fold<double>(0, (a, b) => a < b ? a : b);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;
    final minY = minValue >= 0 ? 0.0 : minValue * 1.2;

    return SizedBox(
      height: 150,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Pedido do utilizador: com muitas barras (ex.: 30 dias) num
          // gráfico estreito, uma largura fixa fazia as barras ficarem
          // encavalitadas/sobrepostas — a largura passa a caber no
          // espaço disponível em vez de ser um valor fixo.
          final barWidth = (constraints.maxWidth / bars.length * 0.5).clamp(
            3.0,
            18.0,
          );
          return BarChart(
            BarChartData(
              maxY: maxY,
              minY: minY,
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
                // Pedido do utilizador: o gráfico não tinha escala nenhuma
                // no eixo dos valores, só as barras — 3 marcas (0, meio,
                // topo) já dão contexto sem poluir um gráfico pequeno.
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: (maxY - minY) / 2,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          formatter.formatCompact(value),
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
                        width: barWidth,
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
          );
        },
      ),
    );
  }
}

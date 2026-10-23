import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/price_history_calc.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/theme/app_theme.dart';

/// Linha do preço da posição ao longo do tempo, com o range (min/max do
/// mint, imutável) desenhado como uma banda — para ver visualmente quanto
/// tempo a posição passou dentro/fora do range, não só o instante atual
/// que o `RangeHealthBar` já mostra.
class PriceRangeChart extends StatelessWidget {
  final List<PricePathPoint> points;
  final int tickLower;
  final int tickUpper;
  final int token0Decimals;
  final int token1Decimals;
  final Color accentColor;

  const PriceRangeChart({
    super.key,
    required this.points,
    required this.tickLower,
    required this.tickUpper,
    required this.token0Decimals,
    required this.token1Decimals,
    required this.accentColor,
  });

  double _price(num tick) => priceAtTick(
    tick: tick,
    token0Decimals: token0Decimals,
    token1Decimals: token1Decimals,
  );

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (points.length < 2) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Ainda sem histórico de preço suficiente',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
      );
    }

    final priceLower = _price(tickLower);
    final priceUpper = _price(tickUpper);
    final linePrices = points.map((p) => _price(p.avgTick)).toList();

    final allValues = [...linePrices, priceLower, priceUpper];
    final dataMin = allValues.reduce((a, b) => a < b ? a : b);
    final dataMax = allValues.reduce((a, b) => a > b ? a : b);
    final pad = (dataMax - dataMin) * 0.1 + (dataMax - dataMin == 0 ? 1 : 0);

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: dataMin - pad,
          maxY: dataMax + pad,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: priceLower,
                y2: priceUpper,
                color: palette.positive.withValues(alpha: 0.1),
              ),
            ],
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
                for (var i = 0; i < linePrices.length; i++)
                  FlSpot(i.toDouble(), linePrices[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              // Pedido do utilizador: degradê em vez de uma cor sólida —
              // a linha vai do accent (mais vivo) a mais transparente, e
              // a área preenchida por baixo reforça a mesma direção.
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.4)],
              ),
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.22),
                    accentColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

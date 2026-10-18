import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/liquidity_profile.dart';
import '../../core/theme/app_theme.dart';

/// Mostra onde está a liquidez de outros LPs na pool, ao redor do range
/// desta posição — para ver se é uma zona concorrida (muita liquidez
/// competindo pelas mesmas fees) ou relativamente vazia.
class LiquidityProfileSection extends StatelessWidget {
  final List<TickLiquidity> profile;
  final int tickLower;
  final int tickUpper;
  final Color accentColor;

  const LiquidityProfileSection({
    super.key,
    required this.profile,
    required this.tickLower,
    required this.tickUpper,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (profile.length < 3) {
      return Text(
        'Ainda sem dados de liquidez suficientes para esta pool',
        style: TextStyle(fontSize: 11.5, color: palette.textTertiary),
      );
    }

    final concentrationPct = computeRangeConcentrationPct(
      profile: profile,
      tickLower: tickLower,
      tickUpper: tickUpper,
    );
    final maxLiquidity = profile.fold<double>(
      0,
      (a, b) => b.liquidityGross > a ? b.liquidityGross : a,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${concentrationPct.toStringAsFixed(0)}% da liquidez desta janela está '
                'dentro do teu range — ${concentrationPct >= 50 ? 'uma zona concorrida' : 'relativamente pouco concorrida'}.',
                style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: BarChart(
            BarChartData(
              maxY: maxLiquidity <= 0 ? 1 : maxLiquidity * 1.1,
              minY: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              barTouchData: BarTouchData(enabled: false),
              barGroups: [
                for (var i = 0; i < profile.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: profile[i].liquidityGross,
                        width: (300 / profile.length).clamp(1.5, 6),
                        color:
                            profile[i].tick >= tickLower &&
                                profile[i].tick <= tickUpper
                            ? accentColor
                            : palette.textSecondary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Barras coloridas = dentro do teu range · cinzentas = fora',
          style: TextStyle(fontSize: 10, color: palette.textTertiary),
        ),
      ],
    );
  }
}

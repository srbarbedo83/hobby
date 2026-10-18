import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/calc/portfolio_composition.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/segmented_pill_control.dart';

enum _CompositionMode { chain, pair }

/// Categórica, não ligada ao significado semântico das cores da app
/// (positive/negative/warning) — cada fatia é só "uma categoria diferente".
const _sliceColors = [
  Color(0xFFFF4FA3),
  Color(0xFF4DD0E1),
  Color(0xFF7B61FF),
  Color(0xFFFFB020),
  Color(0xFF33D17A),
  Color(0xFF4DA3FF),
];

class PortfolioCompositionCard extends StatefulWidget {
  final List<CompositionSlice> byChain;
  final List<CompositionSlice> byPair;
  final CurrencyFormatter formatter;

  const PortfolioCompositionCard({
    super.key,
    required this.byChain,
    required this.byPair,
    required this.formatter,
  });

  @override
  State<PortfolioCompositionCard> createState() =>
      _PortfolioCompositionCardState();
}

class _PortfolioCompositionCardState extends State<PortfolioCompositionCard> {
  _CompositionMode _mode = _CompositionMode.chain;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final slices = _mode == _CompositionMode.chain
        ? widget.byChain
        : widget.byPair;
    final total = slices.fold<double>(0, (a, b) => a + b.valueUsd);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Portfolio composition',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              SizedBox(
                width: 140,
                child: SegmentedPillControl<_CompositionMode>(
                  options: _CompositionMode.values,
                  selected: _mode,
                  labelBuilder: (m) =>
                      m == _CompositionMode.chain ? 'Chain' : 'Pool',
                  onSelected: (m) => setState(() => _mode = m),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (total <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No open positions yet',
                style: TextStyle(color: palette.textTertiary, fontSize: 12),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        for (var i = 0; i < slices.length; i++)
                          PieChartSectionData(
                            value: slices[i].valueUsd,
                            color: _sliceColors[i % _sliceColors.length],
                            showTitle: false,
                            radius: 18,
                          ),
                      ],
                      centerSpaceRadius: 32,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < slices.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == slices.length - 1 ? 0 : 6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _sliceColors[i % _sliceColors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  slices[i].label,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${(slices[i].valueUsd / total * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

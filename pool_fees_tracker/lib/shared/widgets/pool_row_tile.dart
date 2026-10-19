import 'package:flutter/material.dart';

import '../../core/calc/range_health.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/chain.dart';
import '../../data/local/pool_position.dart';
import 'range_status_badge.dart';
import 'sparkline.dart';
import 'token_pair_icon.dart';

class PoolRowTile extends StatelessWidget {
  final PoolPosition position;
  final RangeHealth rangeHealth;
  final List<double> sparklineValues;
  final CurrencyFormatter formatter;
  final VoidCallback? onTap;

  /// 0-100, ver `computePoolHealthScore` — `null` omite o badge.
  final int? healthScore;

  const PoolRowTile({
    super.key,
    required this.position,
    required this.rangeHealth,
    required this.sparklineValues,
    required this.formatter,
    this.onTap,
    this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            TokenPairIcon(
              token0: position.token0Symbol,
              token1: position.token1Symbol,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${position.token0Symbol} / ${position.token1Symbol}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${position.feeTierPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: position.chain.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            position.chain.shortLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: palette.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      RangeStatusPill(status: rangeHealth.status),
                      if (healthScore != null)
                        _HealthScoreBadge(score: healthScore!),
                      if (position.isV4) const _V4Badge(),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatter.format(position.feesTotalUsd),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Sparkline(
                  values: sparklineValues,
                  color: rangeHealth.status.colorFor(palette),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Distingue posições Uniswap v4 das v3 — importa porque em v4 as fees
/// não reclamadas ainda não são calculadas (ver nota em
/// `live_pool_fees_repository.dart`), por isso o valor mostrado nesta
/// posição é só o TVL atual, não inclui fees por reclamar.
class _V4Badge extends StatelessWidget {
  const _V4Badge();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'v4',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: palette.accent,
        ),
      ),
    );
  }
}

/// Pequena pill com o `PoolHealthScore` (0-100): verde/âmbar/vermelho.
class _HealthScoreBadge extends StatelessWidget {
  final int score;

  const _HealthScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = score >= 70
        ? palette.positive
        : score >= 40
        ? palette.warning
        : palette.negative;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/calc/pool_health_score.dart';
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

  /// Ver `computePoolHealthScore` — `null` omite o badge. Guarda os 3
  /// sub-scores (não só o total) para explicar o número ao tocar nele.
  final PoolHealthScore? healthScore;

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
                        _HealthScoreBadge(health: healthScore!),
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
                const SizedBox(height: 2),
                // Valor alocado na posição — pedido do utilizador: entre
                // várias pools, as taxas por si só (sobretudo quando
                // pequenas ou a zero numa posição v4 nova) não bastam para
                // distinguir rapidamente qual é qual; o valor costuma ser
                // o sinal mais reconhecível.
                Text(
                  formatter.format(position.liquidityUsd),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: palette.textTertiary,
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
/// Ao tocar, mostra os 3 sub-scores que compõem o número — sem isto, o
/// número isolado não dizia nada sobre o porquê (pedido do utilizador).
class _HealthScoreBadge extends StatelessWidget {
  final PoolHealthScore health;

  const _HealthScoreBadge({required this.health});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final score = health.score;
    final color = score >= 70
        ? palette.positive
        : score >= 40
        ? palette.warning
        : palette.negative;
    return GestureDetector(
      onTap: () => _showExplanation(context, palette),
      child: Container(
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
      ),
    );
  }

  void _showExplanation(BuildContext context, AppPalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: palette.accent),
                const SizedBox(width: 8),
                Text(
                  'Saúde da pool: ${health.score}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Média destes três sinais:',
              style: TextStyle(fontSize: 12, color: palette.textTertiary),
            ),
            const SizedBox(height: 16),
            _ScoreRow(
              label: 'Dentro do range',
              detail:
                  '100 dentro do range, 60 perto da margem, 0 fora',
              score: health.rangeScore,
              palette: palette,
            ),
            const SizedBox(height: 10),
            _ScoreRow(
              label: 'Tendência de taxas',
              detail:
                  'Últimas 24h vs. a média diária dos últimos 7 dias '
                  '(50 = ainda sem histórico suficiente)',
              score: health.feeTrendScore,
              palette: palette,
            ),
            const SizedBox(height: 10),
            _ScoreRow(
              label: 'Impermanent loss',
              detail: '100 = sem perda; desce quanto maior a perda',
              score: health.ilScore,
              palette: palette,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String detail;
  final int score;
  final AppPalette palette;

  const _ScoreRow({
    required this.label,
    required this.detail,
    required this.score,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? palette.positive
        : score >= 40
        ? palette.warning
        : palette.negative;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              Text(
                detail,
                style: TextStyle(fontSize: 11, color: palette.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

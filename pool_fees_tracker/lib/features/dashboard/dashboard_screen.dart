import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/dashboard_metrics.dart';
import '../../core/calc/impermanent_loss.dart';
import '../../core/calc/pool_health_score.dart';
import '../../core/calc/portfolio_composition.dart';
import '../../core/calc/range_health.dart';
import '../../core/calc/staleness.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/fee_snapshot.dart';
import '../../shared/widgets/animated_usd_number.dart';
import '../../shared/widgets/live_badge.dart';
import '../../shared/widgets/pool_row_tile.dart';
import '../../shared/widgets/stat_tile.dart';
import '../pool_detail/pool_detail_screen.dart';
import 'portfolio_composition_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final positionsAsync = ref.watch(positionsStreamProvider);
    final snapshotsAsync = ref.watch(allFeeSnapshotsProvider);
    final walletsAsync = ref.watch(walletsProvider);

    final positions = positionsAsync.value;
    if (positions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final snapshots =
        snapshotsAsync.value ?? const <String, List<FeeSnapshot>>{};
    final formatter = CurrencyFormatter(settings.currencyCode);
    // O total de fees conta TODAS as posições, incluindo as já fechadas —
    // só a lista "Your Pools" abaixo mostra apenas as abertas.
    final metrics = computeDashboardMetrics(
      positions: positions,
      snapshotsByKey: snapshots,
    );
    final openPositions = positions.where((p) => !p.isClosed).toList();
    final closedCount = positions.length - openPositions.length;
    final walletLabel = walletsAsync.value?.isNotEmpty == true
        ? walletsAsync.value!.first.label
        : '0x7a3f…9c21 (demo)';
    final repository = ref.watch(poolFeesRepositoryProvider);
    final updatedAt = repository.lastUpdatedAt;
    final lastError = repository.lastError;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(poolFeesRepositoryProvider).refreshNow(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _TopBar(walletLabel: walletLabel),
            if (lastError != null) ...[
              const SizedBox(height: 12),
              _LiveErrorBanner(message: lastError),
            ],
            const SizedBox(height: 18),
            _HeroCard(
              totalFeesUsd: metrics.totalFeesUsd,
              fees24hUsd: metrics.fees24hUsd,
              pctChangeVsPrevWeek: metrics.pctChangeVsPrevWeek,
              formatter: formatter,
              updatedAt: updatedAt,
              refreshIntervalSeconds: settings.refreshIntervalSeconds,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Taxas 24h',
                    value: formatter.format(metrics.fees24hUsd),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'APR média',
                    value: '${metrics.avgAprPct.toStringAsFixed(1)}%',
                    valueColor: palette.positive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Não reclamadas',
                    value: formatter.format(metrics.unclaimedUsd),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Proj. este mês',
                    value: formatter.format(
                      metrics.projection.projectedEndOfMonthUsd,
                    ),
                    caption: 'todas as pools, taxa atual',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Proj. este ano',
                    value: formatter.format(
                      metrics.projection.projectedEndOfYearUsd,
                    ),
                    caption: 'todas as pools, taxa atual',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PortfolioCompositionCard(
              byChain: compositionByChain(positions),
              byPair: compositionByPair(positions),
              formatter: formatter,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'As tuas Pools',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                Text(
                  '${openPositions.length} pools',
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final position in openPositions) ...[
              PoolRowTile(
                position: position,
                rangeHealth: computeRangeHealth(
                  tickLower: position.tickLower,
                  tickUpper: position.tickUpper,
                  currentTick: position.currentTick,
                ),
                sparklineValues: _sparklineFor(
                  snapshots[position.positionKey] ?? const [],
                ),
                formatter: formatter,
                healthScore: computePoolHealthScore(
                  rangeStatus: computeRangeHealth(
                    tickLower: position.tickLower,
                    tickUpper: position.tickUpper,
                    currentTick: position.currentTick,
                  ).status,
                  snapshots: snapshots[position.positionKey] ?? const [],
                  impermanentLossPct: computeImpermanentLoss(
                    entryTick: position.entryTick,
                    currentTick: position.currentTick,
                    initialLiquidityUsd: position.initialLiquidityUsd,
                  ).lossPct,
                ).score,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PoolDetailScreen(positionKey: position.positionKey),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (closedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ $closedCount posição${closedCount > 1 ? 'ões' : ''} fechada${closedCount > 1 ? 's' : ''} — '
                  'continuam a contar no total acima. Ver separador Pools.',
                  style: TextStyle(fontSize: 11.5, color: palette.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<double> _sparklineFor(List<FeeSnapshot> snapshots) {
    final bars = aggregateFeeSnapshots(
      snapshots: snapshots,
      range: ChartRange.last7d,
      groupBy: ChartGroupBy.day,
    );
    return bars.map((b) => b.valueUsd).toList();
  }
}

/// Aviso visível quando o último [PoolFeesRepository.refreshNow] falhou em
/// modo Live (rede, API key inválida, schema do subgraph inesperado) — sem
/// isto, um erro ficava só no logcat e o utilizador via o dashboard
/// silenciosamente vazio, sem nenhuma pista do que se passou.
class _LiveErrorBanner extends ConsumerWidget {
  final String message;

  const _LiveErrorBanner({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.negative.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.negative.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: palette.negative, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Não foi possível atualizar as posições',
                  style: TextStyle(
                    color: palette.negative,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.refresh, color: palette.textSecondary, size: 18),
            tooltip: 'Tentar novamente',
            onPressed: () => ref.read(poolFeesRepositoryProvider).refreshNow(),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String walletLabel;

  const _TopBar({required this.walletLabel});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pool Fees Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.accent, const Color(0xFF7B61FF)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                walletLabel,
                style: TextStyle(fontSize: 12, color: palette.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double totalFeesUsd;
  final double fees24hUsd;
  final double? pctChangeVsPrevWeek;
  final CurrencyFormatter formatter;
  final DateTime? updatedAt;
  final int refreshIntervalSeconds;

  const _HeroCard({
    required this.totalFeesUsd,
    required this.fees24hUsd,
    required this.pctChangeVsPrevWeek,
    required this.formatter,
    required this.updatedAt,
    required this.refreshIntervalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL DE TAXAS GANHAS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: palette.textSecondary,
                ),
              ),
              LiveBadge(
                isStale: isDataStale(
                  lastUpdatedAt: updatedAt,
                  refreshIntervalSeconds: refreshIntervalSeconds,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedUsdNumber(value: totalFeesUsd, formatter: formatter),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _DeltaChip(
                text: '+${formatter.format(fees24hUsd)} hoje',
                positive: true,
              ),
              if (pctChangeVsPrevWeek != null)
                _DeltaChip(
                  text:
                      '${pctChangeVsPrevWeek! >= 0 ? '+' : ''}${pctChangeVsPrevWeek!.toStringAsFixed(1)}% vs. 7d anteriores',
                  positive: pctChangeVsPrevWeek! >= 0,
                ),
              if (updatedAt != null)
                Text(
                  formatRelativeUpdatedAt(updatedAt!),
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String text;
  final bool positive;

  const _DeltaChip({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = positive ? palette.positive : palette.negative;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

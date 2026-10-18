import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/dashboard_metrics.dart';
import '../../core/calc/range_health.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/fee_snapshot.dart';
import '../../shared/widgets/animated_usd_number.dart';
import '../../shared/widgets/live_badge.dart';
import '../../shared/widgets/pool_row_tile.dart';
import '../../shared/widgets/stat_tile.dart';
import '../pool_detail/pool_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final metrics = computeDashboardMetrics(
      positions: positions,
      snapshotsByKey: snapshots,
    );
    final walletLabel = walletsAsync.value?.isNotEmpty == true
        ? walletsAsync.value!.first.label
        : '0x7a3f…9c21 (demo)';
    final updatedAt = ref.watch(poolFeesRepositoryProvider).lastUpdatedAt;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(poolFeesRepositoryProvider).refreshNow(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _TopBar(walletLabel: walletLabel),
            const SizedBox(height: 18),
            _HeroCard(
              totalFeesUsd: metrics.totalFeesUsd,
              fees24hUsd: metrics.fees24hUsd,
              pctChangeVsPrevWeek: metrics.pctChangeVsPrevWeek,
              formatter: formatter,
              updatedAt: updatedAt,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: '24h fees',
                    value: formatter.format(metrics.fees24hUsd),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Avg APR',
                    value: '${metrics.avgAprPct.toStringAsFixed(1)}%',
                    valueColor: AppColors.positive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Unclaimed',
                    value: formatter.format(metrics.unclaimedUsd),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Pools',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${positions.length} pools',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final position in positions) ...[
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PoolDetailScreen(positionKey: position.positionKey),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
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

class _TopBar extends StatelessWidget {
  final String walletLabel;

  const _TopBar({required this.walletLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pool Fees Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, Color(0xFF7B61FF)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                walletLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
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

  const _HeroCard({
    required this.totalFeesUsd,
    required this.fees24hUsd,
    required this.pctChangeVsPrevWeek,
    required this.formatter,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL FEES EARNED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
              const LiveBadge(),
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
                text: '+${formatter.format(fees24hUsd)} today',
                positive: true,
              ),
              if (pctChangeVsPrevWeek != null)
                _DeltaChip(
                  text:
                      '${pctChangeVsPrevWeek! >= 0 ? '+' : ''}${pctChangeVsPrevWeek!.toStringAsFixed(1)}% vs prev. 7d',
                  positive: pctChangeVsPrevWeek! >= 0,
                ),
              if (updatedAt != null)
                Text(
                  formatRelativeUpdatedAt(updatedAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
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
    final color = positive ? AppColors.positive : AppColors.negative;
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

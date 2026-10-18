import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/range_health.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../shared/widgets/pool_row_tile.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/token_pair_icon.dart';
import '../pool_detail/pool_detail_screen.dart';

enum _SortBy { fees, apr, age }

extension on _SortBy {
  String get label => switch (this) {
    _SortBy.fees => 'Fees',
    _SortBy.apr => 'APR',
    _SortBy.age => 'Newest',
  };
}

class PoolsScreen extends ConsumerStatefulWidget {
  const PoolsScreen({super.key});

  @override
  ConsumerState<PoolsScreen> createState() => _PoolsScreenState();
}

class _PoolsScreenState extends ConsumerState<PoolsScreen> {
  _SortBy _sortBy = _SortBy.fees;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final positionsAsync = ref.watch(positionsStreamProvider);
    final snapshotsAsync = ref.watch(allFeeSnapshotsProvider);

    final allPositions = positionsAsync.value ?? const <PoolPosition>[];
    final positions = allPositions.where((p) => !p.isClosed).toList();
    final closedPositions = allPositions.where((p) => p.isClosed).toList()
      ..sort(
        (a, b) =>
            (b.closedAt ?? b.createdAt).compareTo(a.closedAt ?? a.createdAt),
      );
    final snapshots =
        snapshotsAsync.value ?? const <String, List<FeeSnapshot>>{};
    final formatter = CurrencyFormatter(settings.currencyCode);

    switch (_sortBy) {
      case _SortBy.fees:
        positions.sort((a, b) => b.feesTotalUsd.compareTo(a.feesTotalUsd));
      case _SortBy.apr:
        positions.sort((a, b) {
          final aprA = _apr7d(a, snapshots);
          final aprB = _apr7d(b, snapshots);
          return aprB.compareTo(aprA);
        });
      case _SortBy.age:
        positions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: SegmentedPillControl<_SortBy>(
                    options: _SortBy.values,
                    selected: _sortBy,
                    labelBuilder: (s) => s.label,
                    onSelected: (s) => setState(() => _sortBy = s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: positions.isEmpty && closedPositions.isEmpty
                  ? const Center(
                      child: Text(
                        'No pools yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final position in positions) ...[
                          PoolRowTile(
                            position: position,
                            rangeHealth: computeRangeHealth(
                              tickLower: position.tickLower,
                              tickUpper: position.tickUpper,
                              currentTick: position.currentTick,
                            ),
                            sparklineValues: aggregateFeeSnapshots(
                              snapshots:
                                  snapshots[position.positionKey] ?? const [],
                              range: ChartRange.last7d,
                              groupBy: ChartGroupBy.day,
                            ).map((b) => b.valueUsd).toList(),
                            formatter: formatter,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PoolDetailScreen(
                                  positionKey: position.positionKey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (closedPositions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'CLOSED (still counted in lifetime total)'
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final position in closedPositions) ...[
                            _ClosedPositionRow(
                              position: position,
                              formatter: formatter,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PoolDetailScreen(
                                    positionKey: position.positionKey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _apr7d(
    PoolPosition position,
    Map<String, List<FeeSnapshot>> snapshots,
  ) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final feesLast7d = (snapshots[position.positionKey] ?? const [])
        .where((s) => s.timestamp.isAfter(cutoff))
        .fold<double>(0, (a, b) => a + b.feesUsdDelta);
    return position.liquidityUsd > 0
        ? (feesLast7d / position.liquidityUsd) * (365 / 7) * 100
        : 0;
  }
}

/// Linha simplificada para uma posição fechada — sem range/sparkline
/// (deixaram de fazer sentido), só o par, há quanto tempo fechou, e o total
/// vitalício de fees que ainda conta para o dashboard.
class _ClosedPositionRow extends StatelessWidget {
  final PoolPosition position;
  final CurrencyFormatter formatter;
  final VoidCallback? onTap;

  const _ClosedPositionRow({
    required this.position,
    required this.formatter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final closedAt = position.closedAt;
    final daysAgo = closedAt == null
        ? null
        : DateTime.now().difference(closedAt).inDays;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: 0.55,
              child: TokenPairIcon(
                token0: position.token0Symbol,
                token1: position.token1Symbol,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${position.token0Symbol} / ${position.token1Symbol}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysAgo != null ? 'Closed ${daysAgo}d ago' : 'Closed',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatter.format(position.feesTotalUsd),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

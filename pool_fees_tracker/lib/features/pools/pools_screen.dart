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

    final positions = [...positionsAsync.value ?? const <PoolPosition>[]];
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
              child: positions.isEmpty
                  ? const Center(
                      child: Text(
                        'No pools yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      itemCount: positions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final position = positions[index];
                        return PoolRowTile(
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
                        );
                      },
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

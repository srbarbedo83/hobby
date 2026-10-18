import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/pool_metrics.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/chain.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/position_event.dart';
import '../../shared/widgets/animated_usd_number.dart';
import '../../shared/widgets/live_badge.dart';
import '../../shared/widgets/range_status_badge.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/stat_tile.dart';
import '../../shared/widgets/token_pair_icon.dart';
import 'fee_bar_chart.dart';

class PoolDetailScreen extends ConsumerStatefulWidget {
  final String positionKey;

  const PoolDetailScreen({super.key, required this.positionKey});

  @override
  ConsumerState<PoolDetailScreen> createState() => _PoolDetailScreenState();
}

class _PoolDetailScreenState extends ConsumerState<PoolDetailScreen> {
  ChartRange _range = ChartRange.last7d;
  ChartGroupBy _groupBy = ChartGroupBy.day;
  int? _selectedBarIndex;

  void _onRangeSelected(ChartRange range) {
    setState(() {
      _range = range;
      if (!range.allowedGroupBys.contains(_groupBy)) {
        _groupBy = range.defaultGroupBy;
      }
      _selectedBarIndex = null;
    });
  }

  void _onGroupBySelected(ChartGroupBy groupBy) {
    setState(() {
      _groupBy = groupBy;
      _selectedBarIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final positionsAsync = ref.watch(positionsStreamProvider);
    final snapshotsAsync = ref.watch(allFeeSnapshotsProvider);

    PoolPosition? position;
    for (final p in positionsAsync.value ?? const <PoolPosition>[]) {
      if (p.positionKey == widget.positionKey) {
        position = p;
        break;
      }
    }

    if (position == null) {
      return Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(),
        body: Center(
          child: Text(
            'Position not found',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      );
    }

    final snapshots = snapshotsAsync.value?[widget.positionKey] ?? const [];
    final formatter = CurrencyFormatter(settings.currencyCode);
    final gasCostUsd = ref.watch(gasCostUsdProvider(widget.positionKey)).value;
    final metrics = computePoolMetrics(
      position: position,
      snapshots: snapshots,
      gasCostUsdOverride: gasCostUsd,
    );
    final bars = aggregateFeeSnapshots(
      snapshots: snapshots,
      range: _range,
      groupBy: _groupBy,
    );
    final selectedBar =
        _selectedBarIndex != null && _selectedBarIndex! < bars.length
        ? bars[_selectedBarIndex!]
        : (bars.isNotEmpty ? bars.last : null);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TokenPairIcon(
              token0: position.token0Symbol,
              token1: position.token1Symbol,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text('${position.token0Symbol} / ${position.token1Symbol}'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${position.feeTierPct.toStringAsFixed(2)}% fee tier',
                    style: TextStyle(
                      fontSize: 11,
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
                    const SizedBox(width: 5),
                    Text(
                      position.chain.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Opened ${DateFormat.yMMMd().format(position.createdAt)}',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
                        'FEES EARNED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: palette.textSecondary,
                        ),
                      ),
                      const LiveBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedUsdNumber(
                    value: position.feesTotalUsd,
                    formatter: formatter,
                    fontSize: 38,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatter.format(metrics.sinceOpen.feesEarnedUsd)} since open '
                    '(+${metrics.sinceOpen.feesEarnedPct.toStringAsFixed(1)}%) · ${metrics.sinceOpen.daysOpen}d open',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.positive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.border),
              ),
              child: RangeHealthBar(
                health: metrics.rangeHealth,
                minPriceLabel: formatTokenPrice(
                  priceAtTick(
                    tick: position.tickLower,
                    token0Decimals: position.token0Decimals,
                    token1Decimals: position.token1Decimals,
                  ),
                ),
                maxPriceLabel: formatTokenPrice(
                  priceAtTick(
                    tick: position.tickUpper,
                    token0Decimals: position.token0Decimals,
                    token1Decimals: position.token1Decimals,
                  ),
                ),
                priceUnitLabel:
                    '${position.token1Symbol} per ${position.token0Symbol}',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'APR (7d)',
                    value: '${metrics.realizedAprPct.toStringAsFixed(1)}%',
                    valueColor: metrics.realizedAprPct >= 0
                        ? palette.positive
                        : palette.negative,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Position value',
                    value: formatter.format(position.liquidityUsd),
                    caption: 'incl. unclaimed fees',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Gas break-even',
                    value: metrics.gasBreakEven.reached
                        ? 'Paid off'
                        : formatter.format(metrics.gasBreakEven.remainingUsd),
                    valueColor: metrics.gasBreakEven.reached
                        ? palette.positive
                        : palette.textPrimary,
                    caption:
                        (metrics.gasBreakEven.reached
                            ? 'fees > gas cost'
                            : metrics.gasBreakEven.estimatedDaysRemaining !=
                                  null
                            ? '~${metrics.gasBreakEven.estimatedDaysRemaining}d left at current rate'
                            : 'left to cover gas') +
                        (gasCostUsd != null ? ' · on-chain' : ''),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Proj. this month',
                    value: formatter.format(
                      metrics.projection.projectedEndOfMonthUsd,
                    ),
                    caption: 'at current daily rate',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StatTile(
              label: 'Proj. this year',
              value: formatter.format(metrics.projection.projectedEndOfYearUsd),
              caption: 'at current daily rate — trend, not a guarantee',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Impermanent loss',
                    value: metrics.impermanentLoss.lossPct > -0.01
                        ? '~0%'
                        : '${metrics.impermanentLoss.lossPct.toStringAsFixed(2)}%',
                    valueColor: metrics.impermanentLoss.lossPct < -0.01
                        ? palette.negative
                        : palette.textPrimary,
                    caption: 'vs. just holding the tokens — est.',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Net vs. HODL',
                    value: formatter.format(metrics.netVsHoldUsd),
                    valueColor: metrics.netVsHoldUsd >= 0
                        ? palette.positive
                        : palette.negative,
                    caption: 'fees earned minus IL',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fees over time',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedPillControl<ChartRange>(
                    options: ChartRange.values,
                    selected: _range,
                    labelBuilder: (r) => r.label,
                    onSelected: _onRangeSelected,
                  ),
                  const SizedBox(height: 8),
                  SegmentedPillControl<ChartGroupBy>(
                    options: _range.allowedGroupBys,
                    selected: _groupBy,
                    labelBuilder: (g) => g.label,
                    onSelected: _onGroupBySelected,
                  ),
                  const SizedBox(height: 14),
                  if (selectedBar != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatter.format(selectedBar.valueUsd),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                        Text(
                          '${selectedBar.label} · ${_range.label}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  FeeBarChart(
                    bars: bars,
                    selectedIndex:
                        _selectedBarIndex ??
                        (bars.isEmpty ? null : bars.length - 1),
                    accentColor: palette.accent,
                    onBarSelected: (index) =>
                        setState(() => _selectedBarIndex = index),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ActivitySection(
              positionKey: widget.positionKey,
              formatter: formatter,
            ),
          ],
        ),
      ),
    );
  }
}

extension on PositionEventType {
  String get label => switch (this) {
    PositionEventType.mint => 'Position opened',
    PositionEventType.increaseLiquidity => 'Added liquidity',
    PositionEventType.decreaseLiquidity => 'Removed liquidity',
    PositionEventType.collect => 'Collected fees',
  };

  IconData get icon => switch (this) {
    PositionEventType.mint => Icons.add_circle_outline,
    PositionEventType.increaseLiquidity => Icons.arrow_upward,
    PositionEventType.decreaseLiquidity => Icons.arrow_downward,
    PositionEventType.collect => Icons.redeem_outlined,
  };

  Color colorFor(AppPalette palette) => switch (this) {
    PositionEventType.mint => palette.accent,
    PositionEventType.increaseLiquidity => palette.positive,
    PositionEventType.decreaseLiquidity => palette.warning,
    PositionEventType.collect => palette.positive,
  };
}

class _ActivitySection extends ConsumerWidget {
  final String positionKey;
  final CurrencyFormatter formatter;

  const _ActivitySection({required this.positionKey, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final eventsAsync = ref.watch(positionEventsProvider(positionKey));

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
          Text(
            'Activity',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          eventsAsync.when(
            data: (events) => events.isEmpty
                ? Text(
                    'No events yet',
                    style: TextStyle(fontSize: 12, color: palette.textTertiary),
                  )
                : Column(
                    children: [
                      for (final event in events) ...[
                        _EventRow(event: event, formatter: formatter),
                        if (event != events.last) const SizedBox(height: 10),
                      ],
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, st) => Text(
              'Could not load activity',
              style: TextStyle(fontSize: 12, color: palette.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final PositionEvent event;
  final CurrencyFormatter formatter;

  const _EventRow({required this.event, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = event.type.colorFor(palette);
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(event.type.icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.type.label,
                style: TextStyle(fontSize: 13, color: palette.textPrimary),
              ),
              Text(
                DateFormat.yMMMd().add_Hm().format(event.timestamp),
                style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
              ),
            ],
          ),
        ),
        Text(
          formatter.format(event.amountUsd),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

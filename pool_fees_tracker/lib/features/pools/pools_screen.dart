import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/impermanent_loss.dart';
import '../../core/calc/leaderboard.dart';
import '../../core/calc/pool_health_score.dart';
import '../../core/calc/range_health.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/wallet.dart';
import '../../shared/widgets/pool_row_tile.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/token_pair_icon.dart';
import '../compare/compare_screen.dart';
import '../pool_detail/pool_detail_screen.dart';

enum _SortBy { fees, apr, age }

extension on _SortBy {
  String get label => switch (this) {
    _SortBy.fees => 'Taxas',
    _SortBy.apr => 'APR',
    _SortBy.age => 'Recentes',
  };
}

class PoolsScreen extends ConsumerStatefulWidget {
  const PoolsScreen({super.key});

  @override
  ConsumerState<PoolsScreen> createState() => _PoolsScreenState();
}

class _PoolsScreenState extends ConsumerState<PoolsScreen> {
  _SortBy _sortBy = _SortBy.fees;
  String? _selectedWalletAddress;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final positionsAsync = ref.watch(positionsStreamProvider);
    final snapshotsAsync = ref.watch(allFeeSnapshotsProvider);
    final wallets = ref.watch(walletsProvider).value ?? const <Wallet>[];

    final allPositionsUnfiltered =
        positionsAsync.value ?? const <PoolPosition>[];
    final allPositions = _selectedWalletAddress == null
        ? allPositionsUnfiltered
        : allPositionsUnfiltered
              .where((p) => p.walletAddress == _selectedWalletAddress)
              .toList();
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
                Row(
                  children: [
                    Text(
                      'Pools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                      ),
                    ),
                    if (positions.length >= 2)
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CompareScreen(),
                          ),
                        ),
                        icon: Icon(
                          Icons.compare_arrows,
                          size: 20,
                          color: palette.textSecondary,
                        ),
                        tooltip: 'Comparar pools',
                      ),
                  ],
                ),
                SizedBox(
                  width: 160,
                  child: SegmentedPillControl<_SortBy>(
                    options: _SortBy.values,
                    selected: _sortBy,
                    labelBuilder: (s) => s.label,
                    onSelected: (s) => setState(() => _sortBy = s),
                  ),
                ),
              ],
            ),
            if (wallets.length > 1) ...[
              const SizedBox(height: 10),
              _WalletFilterRow(
                wallets: wallets,
                selectedAddress: _selectedWalletAddress,
                onSelected: (address) =>
                    setState(() => _selectedWalletAddress = address),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: positions.isEmpty && closedPositions.isEmpty
                  ? Center(
                      child: Text(
                        'Ainda sem pools',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    )
                  : ListView(
                      children: [
                        if (positions.isNotEmpty) ...[
                          _LeaderboardRow(
                            leaderboard: computeLeaderboard(
                              positions: allPositions,
                              snapshotsByKey: snapshots,
                            ),
                            formatter: formatter,
                            onTap: (positionKey) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PoolDetailScreen(positionKey: positionKey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
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
                            healthScore: computePoolHealthScore(
                              rangeStatus: computeRangeHealth(
                                tickLower: position.tickLower,
                                tickUpper: position.tickUpper,
                                currentTick: position.currentTick,
                              ).status,
                              snapshots:
                                  snapshots[position.positionKey] ?? const [],
                              impermanentLossPct: computeImpermanentLoss(
                                entryTick: position.entryTick,
                                currentTick: position.currentTick,
                                initialLiquidityUsd:
                                    position.initialLiquidityUsd,
                              ).lossPct,
                            ).score,
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
                            'FECHADAS (continuam a contar no total vitalício)'
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: palette.textTertiary,
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

/// Filtro horizontal por carteira — só aparece quando há mais do que uma
/// carteira seguida, para não ocupar espaço sem necessidade.
class _WalletFilterRow extends StatelessWidget {
  final List<Wallet> wallets;
  final String? selectedAddress;
  final ValueChanged<String?> onSelected;

  const _WalletFilterRow({
    required this.wallets,
    required this.selectedAddress,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _WalletFilterChip(
            label: 'Todas',
            selected: selectedAddress == null,
            onTap: () => onSelected(null),
          ),
          for (final wallet in wallets) ...[
            const SizedBox(width: 6),
            _WalletFilterChip(
              label: wallet.label,
              selected: selectedAddress == wallet.address,
              onTap: () => onSelected(wallet.address),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WalletFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.accent : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? palette.background : palette.textSecondary,
          ),
        ),
      ),
    );
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
    final palette = AppPalette.of(context);
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
          color: palette.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
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
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysAgo != null ? 'Fechada há ${daysAgo}d' : 'Fechada',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatter.format(position.feesTotalUsd),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resumo rápido de "o que está a compensar": a pool com melhor APR (7d) e
/// a com maior perda de impermanent loss, lado a lado — ver
/// `computeLeaderboard`.
class _LeaderboardRow extends StatelessWidget {
  final ({LeaderboardEntry? bestApr, LeaderboardEntry? worstIl}) leaderboard;
  final CurrencyFormatter formatter;
  final ValueChanged<String> onTap;

  const _LeaderboardRow({
    required this.leaderboard,
    required this.formatter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final best = leaderboard.bestApr;
    final worst = leaderboard.worstIl;
    if (best == null && worst == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (best != null)
          Expanded(
            child: _LeaderboardCard(
              label: 'Melhor APR',
              pair:
                  '${best.position.token0Symbol} / ${best.position.token1Symbol}',
              value: '${best.aprPct.toStringAsFixed(1)}%',
              isPositive: true,
              onTap: () => onTap(best.position.positionKey),
            ),
          ),
        if (best != null && worst != null) const SizedBox(width: 10),
        if (worst != null && worst.ilLossPct < -0.01)
          Expanded(
            child: _LeaderboardCard(
              label: 'Pior IL',
              pair:
                  '${worst.position.token0Symbol} / ${worst.position.token1Symbol}',
              value: '${worst.ilLossPct.toStringAsFixed(2)}%',
              isPositive: false,
              onTap: () => onTap(worst.position.positionKey),
            ),
          ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final String label;
  final String pair;
  final String value;
  final bool isPositive;
  final VoidCallback onTap;

  const _LeaderboardCard({
    required this.label,
    required this.pair,
    required this.value,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final accent = isPositive ? palette.positive : palette.negative;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.emoji_events_outlined
                      : Icons.trending_down,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              pair,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

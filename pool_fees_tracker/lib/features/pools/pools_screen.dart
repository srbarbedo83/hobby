import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/eth_benchmark.dart';
import '../../core/calc/impermanent_loss.dart';
import '../../core/calc/leaderboard.dart';
import '../../core/calc/pool_health_score.dart';
import '../../core/calc/portfolio_heatmap.dart';
import '../../core/calc/range_health.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/calc/weighted_entry_price.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/chain.dart';
import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/wallet.dart';
import '../../shared/widgets/info_sheet.dart';
import '../../shared/widgets/pool_row_tile.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/token_pair_icon.dart';
import '../compare/compare_screen.dart';
import '../pool_detail/pool_detail_screen.dart';

enum _SortBy { fees, apr, efficiency, age }

extension on _SortBy {
  String get label => switch (this) {
    _SortBy.fees => 'Taxas',
    _SortBy.apr => 'APR',
    _SortBy.efficiency => 'Eficaz',
    _SortBy.age => 'Recentes',
  };
}

/// % do capital inicial gerado em taxas, por dia, ao longo de TODA a vida
/// da posição — ao contrário da APR (7d), não é anualizado nem só olha
/// para a semana mais recente, por isso ordena diferente: uma pool com um
/// primeiro mês excelente mas parada há semanas continua "eficiente" aqui,
/// mesmo com APR (7d) baixa agora. Pedido do utilizador: "ranking de
/// eficiência de capital (fees/dia por $ investido)".
double _capitalEfficiencyPctPerDay(PoolPosition position) {
  if (position.initialLiquidityUsd <= 0) return 0;
  final daysOpen = DateTime.now().difference(position.createdAt).inHours ~/ 24;
  final effectiveDays = daysOpen < 1 ? 1 : daysOpen;
  return position.feesTotalUsd /
      effectiveDays /
      position.initialLiquidityUsd *
      100;
}

/// Agrupa posições abertas pelo mesmo par (chain + token0 + token1) — só
/// interessante quando há 2+ posições no mesmo par, para mostrar um preço
/// de entrada combinado (ver `_PairEntryPriceCard`).
Map<String, List<PoolPosition>> _groupByPair(List<PoolPosition> positions) {
  final groups = <String, List<PoolPosition>>{};
  for (final p in positions) {
    final key = '${p.chain.name}:${p.token0Symbol}/${p.token1Symbol}';
    groups.putIfAbsent(key, () => []).add(p);
  }
  return groups;
}

class PoolsScreen extends ConsumerStatefulWidget {
  const PoolsScreen({super.key});

  @override
  ConsumerState<PoolsScreen> createState() => _PoolsScreenState();
}

class _PoolsScreenState extends ConsumerState<PoolsScreen> {
  _SortBy _sortBy = _SortBy.fees;
  String? _selectedWalletAddress;
  bool _showInsights = false;

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
    // v4 fechadas não têm informação útil nenhuma para mostrar: sem
    // subgraph, não há como saber quando fecharam nem quanto geraram no
    // total (uma vez a liquidez a 0, o cálculo on-chain das fees também
    // vai sempre a 0) — aparecer na lista só como "Fechada · $0,00" não
    // ajuda em nada (pedido do utilizador), por isso ficam de fora.
    final closedPositions =
        allPositions.where((p) => p.isClosed && !p.isV4).toList()..sort(
          (a, b) =>
              (b.closedAt ?? b.createdAt).compareTo(a.closedAt ?? a.createdAt),
        );
    final snapshots =
        snapshotsAsync.value ?? const <String, List<FeeSnapshot>>{};
    final formatter = CurrencyFormatter(settings.currencyCode);
    final multiPositionPairs = _groupByPair(positions).values
        .where((g) => g.length >= 2)
        .toList();
    final heatmapCells = computePortfolioHeatmap(positions);
    final ethBenchmark = computeEthBenchmark(positions);

    switch (_sortBy) {
      case _SortBy.fees:
        positions.sort((a, b) => b.feesTotalUsd.compareTo(a.feesTotalUsd));
      case _SortBy.apr:
        positions.sort((a, b) {
          final aprA = _apr7d(a, snapshots);
          final aprB = _apr7d(b, snapshots);
          return aprB.compareTo(aprA);
        });
      case _SortBy.efficiency:
        positions.sort(
          (a, b) =>
              _capitalEfficiencyPctPerDay(b)
                  .compareTo(_capitalEfficiencyPctPerDay(a)),
        );
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
                  width: 200,
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
              const SizedBox(height: 10),
              _WalletSummaryStrip(
                wallets: wallets,
                allPositions: allPositionsUnfiltered,
                formatter: formatter,
              ),
            ],
            if (multiPositionPairs.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final group in multiPositionPairs) ...[
                _PairEntryPriceCard(positions: group, formatter: formatter),
                const SizedBox(height: 8),
              ],
            ],
            if (heatmapCells.isNotEmpty || ethBenchmark != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => setState(() => _showInsights = !_showInsights),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _showInsights ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: palette.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Concentração & benchmark',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showInsights) ...[
                const SizedBox(height: 8),
                if (heatmapCells.isNotEmpty) ...[
                  _HeatmapCard(cells: heatmapCells, formatter: formatter),
                  const SizedBox(height: 8),
                ],
                if (ethBenchmark != null) ...[
                  _EthBenchmarkCard(result: ethBenchmark, formatter: formatter),
                  const SizedBox(height: 8),
                ],
              ],
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
                            ),
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

/// Resumo por carteira — pedido do utilizador: já havia um filtro por
/// carteira, mas não um sítio para ver o total de cada uma de uma vez.
/// Usa SEMPRE todas as posições (ignora o filtro ativo), para a carteira
/// selecionada continuar visível na lista mesmo depois de a escolher.
class _WalletSummaryStrip extends StatelessWidget {
  final List<Wallet> wallets;
  final List<PoolPosition> allPositions;
  final CurrencyFormatter formatter;

  const _WalletSummaryStrip({
    required this.wallets,
    required this.allPositions,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final wallet in wallets) ...[
            _WalletSummaryCard(
              wallet: wallet,
              positions: allPositions
                  .where((p) => p.walletAddress == wallet.address)
                  .toList(),
              formatter: formatter,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _WalletSummaryCard extends StatelessWidget {
  final Wallet wallet;
  final List<PoolPosition> positions;
  final CurrencyFormatter formatter;

  const _WalletSummaryCard({
    required this.wallet,
    required this.positions,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final openCount = positions.where((p) => !p.isClosed).length;
    final totalFeesUsd = positions.fold<double>(
      0,
      (a, p) => a + p.feesTotalUsd,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${wallet.label} · $openCount pool${openCount == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 10, color: palette.textTertiary),
          ),
          Text(
            formatter.format(totalFeesUsd),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mostra o preço médio de entrada (ponderado pelo capital inicial) de
/// todas as posições abertas no mesmo par, vs. o preço atual — útil
/// quando reentraste no mesmo par ou mantens várias ranges em paralelo e
/// queres um ponto de entrada combinado, não só o de cada posição.
class _PairEntryPriceCard extends StatelessWidget {
  final List<PoolPosition> positions;
  final CurrencyFormatter formatter;

  const _PairEntryPriceCard({required this.positions, required this.formatter});

  String _formatPrice(double price) =>
      price < 1 ? price.toStringAsFixed(6) : price.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final avgEntryPrice = weightedAverageEntryPrice(positions);
    if (avgEntryPrice == null) return const SizedBox.shrink();
    final first = positions.first;
    final currentPrice = priceAtTick(
      tick: first.currentTick,
      token0Decimals: first.token0Decimals,
      token1Decimals: first.token1Decimals,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${first.token0Symbol}/${first.token1Symbol} · entrada média (${positions.length} posições)',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatPrice(avgEntryPrice),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Atual',
                style: TextStyle(fontSize: 11, color: palette.textTertiary),
              ),
              Text(
                _formatPrice(currentPrice),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: currentPrice >= avgEntryPrice
                      ? palette.positive
                      : palette.negative,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => showInfoSheet(
              context,
              title: 'Entrada média',
              body: const InfoSheetText(
                'Preço médio de entrada de todas as posições abertas '
                'neste par, ponderado pelo capital inicial de cada uma '
                '— uma posição grande pesa mais no cálculo do que uma '
                'pequena. Útil quando reentraste no mesmo par várias '
                'vezes, ou mantens mais do que uma range em paralelo, '
                'e queres um ponto de entrada combinado em vez de olhar '
                'a cada posição isolada.',
              ),
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: palette.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Heatmap de concentração: quanto do valor total está em cada
/// cruzamento chain+par — mais fino do que os donuts de composição
/// (chain OU par, nunca os dois juntos). Mostra só as 5 maiores células,
/// uma barra de intensidade por linha em vez de uma grelha 2D real, para
/// caber num espaço compacto sem precisar de scroll horizontal.
class _HeatmapCard extends StatelessWidget {
  final List<HeatmapCell> cells;
  final CurrencyFormatter formatter;

  const _HeatmapCard({required this.cells, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final topCells = cells.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Concentração por chain + par',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => showInfoSheet(
                  context,
                  title: 'Concentração por chain + par',
                  body: const InfoSheetText(
                    'Quanto do valor total da carteira está em cada '
                    'combinação de chain + par de tokens — mais fino do '
                    'que olhar só a chain ou só o par isoladamente. Uma '
                    'barra muito maior que as outras é um sinal de '
                    'concentração: se essa pool tiver um problema (hack, '
                    'depeg, liquidez a secar), afeta uma fatia grande da '
                    'carteira toda.',
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final cell in topCells) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cell.pairLabel} · ${cell.chain.displayName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        '${cell.pctOfTotal.toStringAsFixed(0)}% · ${formatter.format(cell.valueUsd)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cell.pctOfTotal / 100).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: palette.surfaceAlt,
                      color: cell.pctOfTotal >= 50
                          ? palette.warning
                          : palette.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compara o valor atual das posições em pares ETH/stablecoin com o que
/// esse mesmo capital valeria se, em vez de dar liquidez, tivesse só
/// comprado e guardado ETH desde a abertura de cada posição.
class _EthBenchmarkCard extends StatelessWidget {
  final EthBenchmarkResult result;
  final CurrencyFormatter formatter;

  const _EthBenchmarkCard({required this.result, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vs. guardar ETH (${result.eligiblePositionsCount} posições)',
                  style: TextStyle(fontSize: 12, color: palette.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(result.netVsEthUsd),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: result.netVsEthUsd >= 0
                        ? palette.positive
                        : palette.negative,
                  ),
                ),
                Text(
                  result.netVsEthUsd >= 0
                      ? 'compensou dar liquidez em vez de guardar ETH'
                      : 'terias saído a ganhar só a guardar ETH',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showInfoSheet(
              context,
              title: 'Vs. guardar ETH',
              body: const InfoSheetText(
                'Compara o valor atual das posições em pares ETH/'
                'stablecoin com o que esse mesmo capital valeria se, em '
                'vez de dar liquidez, tivesse só comprado ETH no momento '
                'de abertura de cada posição e continuado a guardá-lo.\n\n'
                'Só entram posições ETH/stablecoin (ETH/USDC, por '
                'exemplo) — para outros pares não há forma honesta de '
                'estimar o preço do ETH sem um histórico de preço que a '
                'app não guarda.\n\n'
                'Positivo: valeu mais a pena dar liquidez do que só '
                'guardar ETH. Negativo: terias saído a ganhar só a '
                'guardar.',
              ),
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: palette.textTertiary,
            ),
          ),
        ],
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

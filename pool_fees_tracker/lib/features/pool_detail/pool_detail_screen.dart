import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/calc/apr_history.dart';
import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/close_now_simulation.dart';
import '../../core/calc/out_of_range_estimate.dart';
import '../../core/calc/staleness.dart';
import '../../core/calc/pool_metrics.dart';
import '../../core/export/position_summary.dart';
import '../../core/calc/price_history_calc.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/chain.dart';
import '../../data/local/pool_position.dart';
import '../../data/local/position_event.dart';
import '../../data/services/export_service.dart';
import '../../shared/widgets/animated_usd_number.dart';
import '../../shared/widgets/info_sheet.dart';
import '../../shared/widgets/live_badge.dart';
import '../../shared/widgets/range_status_badge.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/stat_tile.dart';
import '../../shared/widgets/token_pair_icon.dart';
import 'apr_history_chart.dart';
import 'fee_bar_chart.dart';
import 'liquidity_profile_section.dart';
import 'price_alert_section.dart';
import 'price_range_chart.dart';
import 'range_simulator_section.dart';

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
            'Posição não encontrada',
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
      );
    }

    final snapshots = snapshotsAsync.value?[widget.positionKey] ?? const [];
    final pricePoints =
        ref.watch(pricePointsProvider(widget.positionKey)).value ?? const [];
    final liquidityProfile =
        ref.watch(liquidityProfileProvider(widget.positionKey)).value ??
        const [];
    final formatter = CurrencyFormatter(settings.currencyCode);
    final lastUpdatedAt = ref.watch(poolFeesRepositoryProvider).lastUpdatedAt;
    final gasCostUsd = ref.watch(gasCostUsdProvider(widget.positionKey)).value;
    final metrics = computePoolMetrics(
      position: position,
      snapshots: snapshots,
      gasCostUsdOverride: gasCostUsd,
    );
    final closeNowSim = computeCloseNowSimulation(position: position);
    final outOfRangeEstimate = estimateMissedFees(
      pricePoints: pricePoints,
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
      feesTotalUsd: position.feesTotalUsd,
      createdAt: position.createdAt,
    );
    final rebalanceSuggestion = suggestRebalance(
      position: position,
      estimate: outOfRangeEstimate,
    );
    final inRangeStreak = inRangeStreakDays(
      points: pricePoints,
      tickLower: position.tickLower,
      tickUpper: position.tickUpper,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Partilhar resumo',
            onPressed: () => ExportService.sharePositionSummary(
              buildPositionSummaryText(
                position: position!,
                metrics: metrics,
                formatter: formatter,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Exportar CSV',
            onPressed: () async {
              final events = await ref.read(
                positionEventsProvider(widget.positionKey).future,
              );
              await ExportService.shareFeeHistoryCsv(
                pairLabel: '${position!.token0Symbol}_${position.token1Symbol}',
                snapshots: snapshots,
                events: events,
              );
            },
          ),
        ],
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
                  'Aberta em ${DateFormat.yMMMd().format(position.createdAt)}',
                  style: TextStyle(fontSize: 11, color: palette.textTertiary),
                ),
              ],
            ),
            if (position.isV4) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Posição Uniswap v4 — as taxas não reclamadas já são '
                  'reais (lidas on-chain), e o custo de gás cobre o mint '
                  'da posição (recibo da transação). O lucro/perda "desde '
                  'a abertura" e o gás de increases/collects posteriores '
                  'ainda não estão disponíveis para v4 (só v3), por isso '
                  'aparecem a 0.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ),
            ],
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
                        'TAXAS GERADAS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: palette.textSecondary,
                        ),
                      ),
                      LiveBadge(
                        isStale: isDataStale(
                          lastUpdatedAt: lastUpdatedAt,
                          refreshIntervalSeconds:
                              settings.refreshIntervalSeconds,
                        ),
                      ),
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
                    '${formatter.format(metrics.sinceOpen.feesEarnedUsd)} desde a abertura '
                    '(+${metrics.sinceOpen.feesEarnedPct.toStringAsFixed(1)}%) · ${metrics.sinceOpen.daysOpen}d aberta',
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.positive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (position.feesUnclaimedUsd > 0.009) ...[
                    const SizedBox(height: 10),
                    _UnclaimedFeesChip(
                      valueUsd: position.feesUnclaimedUsd,
                      formatter: formatter,
                      palette: palette,
                    ),
                  ],
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
                    '${position.token1Symbol} por ${position.token0Symbol}',
              ),
            ),
            if (outOfRangeEstimate != null) ...[
              const SizedBox(height: 14),
              _OutOfRangeAdvisory(
                estimate: outOfRangeEstimate,
                rebalanceSuggestion: rebalanceSuggestion,
                position: position,
                formatter: formatter,
              ),
            ],
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'APR (7d)',
                      value: '${metrics.realizedAprPct.toStringAsFixed(1)}%',
                      valueColor: metrics.realizedAprPct >= 0
                          ? palette.positive
                          : palette.negative,
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'APR (7d)',
                        body: const InfoSheetText(
                          'Taxa de retorno anualizada, calculada a partir '
                          'das fees dos últimos 7 dias e do valor atual da '
                          'posição. Como é anualizada, amplifica o que '
                          'aconteceu numa semana — uma posição nova (sem 7 '
                          'dias de histórico ainda) mostra um número pouco '
                          'fiável até esse histórico se preencher.',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Valor da posição',
                      value: formatter.format(position.liquidityUsd),
                      caption: 'incl. taxas não reclamadas',
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'Valor da posição',
                        body: const InfoSheetText(
                          'Valor atual dos dois tokens que tens depositados '
                          'nesta posição, ao preço de mercado de agora, '
                          'incluindo as taxas ainda não reclamadas (a '
                          'pool já as deve, mesmo antes do collect()).',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Gas break-even',
                      value: metrics.gasBreakEven.reached
                          ? 'Pago'
                          : formatter.format(metrics.gasBreakEven.remainingUsd),
                      valueColor: metrics.gasBreakEven.reached
                          ? palette.positive
                          : palette.textPrimary,
                      caption:
                          (metrics.gasBreakEven.reached
                              ? 'taxas > custo de gas'
                              : metrics.gasBreakEven.estimatedDaysRemaining !=
                                    null
                              ? '~${metrics.gasBreakEven.estimatedDaysRemaining}d restantes à taxa atual'
                              : 'para cobrir o gas') +
                          (gasCostUsd != null ? ' · on-chain' : ''),
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'Gas break-even',
                        body: const InfoSheetText(
                          'Quantas taxas ainda faltam gerar para cobrir o '
                          'custo de gás gasto a abrir a posição. "Pago" '
                          'significa que as taxas já geradas já cobrem '
                          'esse custo.\n\n'
                          'Para posições v4, o custo de gás só cobre o '
                          'mint — increases/decreases/collects '
                          'posteriores ao mesmo tokenId ainda não estão '
                          'incluídos (precisariam do histórico completo '
                          'de eventos, que continua indisponível).',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      label: 'Proj. este mês',
                      value: formatter.format(
                        metrics.projection.projectedEndOfMonthUsd,
                      ),
                      caption: 'à taxa diária dos últimos 7 dias',
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'Projeção deste mês/ano',
                        body: const InfoSheetText(
                          'Pega na taxa diária média dos últimos 7 dias e '
                          'estende até ao fim do mês/ano — é uma tendência, '
                          'não uma garantia (preços e liquidez mudam).\n\n'
                          'Numa posição v4 acabada de adicionar ainda não '
                          'há 7 dias de histórico — o número só fica '
                          'fiável depois de uma semana de refreshes.',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            StatTile(
              label: 'Proj. este ano',
              value: formatter.format(metrics.projection.projectedEndOfYearUsd),
              caption: 'à taxa diária atual — tendência, não garantia',
              onInfoTap: () => showInfoSheet(
                context,
                title: 'Projeção deste mês/ano',
                body: const InfoSheetText(
                  'Pega na taxa diária média dos últimos 7 dias e estende '
                  'até ao fim do mês/ano — é uma tendência, não uma '
                  'garantia (preços e liquidez mudam).\n\n'
                  'Numa posição v4 acabada de adicionar ainda não há 7 '
                  'dias de histórico — o número só fica fiável depois de '
                  'uma semana de refreshes.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      caption: 'vs. só guardar os tokens — estimativa',
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'Impermanent loss',
                        body: const _ImpermanentLossExplainer(),
                      ),
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
                      caption: 'taxas geradas menos IL',
                      onInfoTap: () => showInfoSheet(
                        context,
                        title: 'Net vs. HODL',
                        body: const InfoSheetText(
                          'Compara o que ganhaste a fornecer liquidez com '
                          'o que terias se só tivesses guardado os dois '
                          'tokens na carteira, sem fazer nada.\n\n'
                          'Net vs. HODL = taxas geradas − impermanent loss.\n\n'
                          'Positivo: compensou fornecer liquidez. '
                          'Negativo: terias saído a ganhar só a guardar '
                          'os tokens (o IL comeu mais do que as taxas '
                          'deram).',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            StatTile(
              label: 'Streak em range',
              value:
                  '${inRangeStreak.current} dia${inRangeStreak.current == 1 ? '' : 's'}',
              valueColor: inRangeStreak.current > 0
                  ? palette.positive
                  : palette.textPrimary,
              caption: 'recorde: ${inRangeStreak.longest}d',
              onInfoTap: () => showInfoSheet(
                context,
                title: 'Streak em range',
                body: const InfoSheetText(
                  'Quantos dias consecutivos, até hoje, o preço se '
                  'manteve dentro do teu range — zero se o preço está '
                  'fora do range agora. "Recorde" é a sequência mais '
                  'longa já vista desde que a app começou a registar o '
                  'histórico de preço desta posição.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            StatTile(
              label: 'Se fechasses agora',
              value: formatter.format(closeNowSim.netReceivedUsd),
              valueColor: closeNowSim.netProfitSinceOpenUsd >= 0
                  ? palette.positive
                  : palette.negative,
              caption:
                  'lucro desde a abertura: '
                  '${formatter.format(closeNowSim.netProfitSinceOpenUsd)}',
              onInfoTap: () => showInfoSheet(
                context,
                title: 'Se fechasses agora',
                body: const InfoSheetText(
                  'Simula fechar esta posição agora: o que receberias '
                  '(valor atual + fees já reclamadas) menos o gás '
                  'estimado da saída (decreaseLiquidity + collect + '
                  'burn).\n\n'
                  'Como não há forma de simular a transação sem a '
                  'executar, assume-se que fechar custa aproximadamente '
                  'o mesmo gás que abriu a posição — uma aproximação, '
                  'não o valor exato.\n\n'
                  '"Lucro desde a abertura" conta tudo: capital '
                  'depositado, gás já pago e este gás estimado da '
                  'saída — diferente do "Net vs. HODL", que não inclui '
                  'nenhum custo de gás.',
                ),
              ),
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
                    'Taxas ao longo do tempo',
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
                    formatter: formatter,
                    onBarSelected: (index) =>
                        setState(() => _selectedBarIndex = index),
                  ),
                ],
              ),
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
                    'APR ao longo do tempo',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'APR anualizada implícita em cada barra, à liquidez atual da posição',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AprHistoryChart(
                    points: computeAprHistory(
                      snapshots: snapshots,
                      liquidityUsd: position.liquidityUsd,
                      range: _range,
                      groupBy: _groupBy,
                    ),
                    accentColor: palette.accent,
                  ),
                ],
              ),
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
                    'Preço vs. range',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A faixa sombreada é o range criado no mint — ${position.token1Symbol} por ${position.token0Symbol}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: palette.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PriceRangeChart(
                    points: aggregatePricePoints(
                      points: pricePoints,
                      range: _range,
                      groupBy: _groupBy,
                    ),
                    tickLower: position.tickLower,
                    tickUpper: position.tickUpper,
                    token0Decimals: position.token0Decimals,
                    token1Decimals: position.token1Decimals,
                    accentColor: palette.accent,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: palette.border, height: 1),
                  const SizedBox(height: 12),
                  PriceAlertSection(
                    positionKey: widget.positionKey,
                    token0Decimals: position.token0Decimals,
                    token1Decimals: position.token1Decimals,
                    token0Symbol: position.token0Symbol,
                    token1Symbol: position.token1Symbol,
                  ),
                ],
              ),
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
                  Row(
                    children: [
                      Text(
                        'Simulador de largura de range',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => showInfoSheet(
                          context,
                          title: 'Simulador de largura de range',
                          body: const InfoSheetText(
                            'Testa larguras de range diferentes (0.5×, 1×, '
                            '2×, ...) contra o histórico de preço já '
                            'gravado desta posição, e mostra duas coisas '
                            'por largura:\n\n'
                            '"% em range" — quanto tempo o preço passou '
                            'dentro desse range, no período gravado.\n\n'
                            '"×" — o score relativo de fees: um range mais '
                            'estreito concentra a mesma liquidez numa faixa '
                            'de preço menor, por isso ganha mais fees '
                            'ENQUANTO está em range (score > 1×), mas fica '
                            'fora do range mais vezes. Um range mais largo '
                            'é o contrário: menos fees quando está em '
                            'range, mas fica em range mais tempo.\n\n'
                            'É uma estimativa (assume que a tua parte da '
                            'liquidez da pool seria igual com outra '
                            'largura, o que na prática não é bem assim), '
                            'não uma previsão.',
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 13,
                          color: palette.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RangeSimulatorSection(
                    pricePoints: pricePoints,
                    actualTickLower: position.tickLower,
                    actualTickUpper: position.tickUpper,
                    entryTick: position.entryTick,
                    token0Decimals: position.token0Decimals,
                    token1Decimals: position.token1Decimals,
                    token0Symbol: position.token0Symbol,
                    token1Symbol: position.token1Symbol,
                  ),
                ],
              ),
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
                    'Concentração de liquidez',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LiquidityProfileSection(
                    profile: liquidityProfile,
                    tickLower: position.tickLower,
                    tickUpper: position.tickUpper,
                    accentColor: palette.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ActivitySection(
              positionKey: widget.positionKey,
              formatter: formatter,
              isV4: position.isV4,
            ),
          ],
        ),
      ),
    );
  }
}

extension on PositionEventType {
  String get label => switch (this) {
    PositionEventType.mint => 'Posição aberta',
    PositionEventType.increaseLiquidity => 'Liquidez adicionada',
    PositionEventType.decreaseLiquidity => 'Liquidez removida',
    PositionEventType.collect => 'Taxas recolhidas',
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

/// Destaque visual para as taxas por reclamar — pedido do utilizador: o
/// valor ficava "escondido" dentro do total de taxas geradas (que inclui as
/// já reclamadas), por isso ganha aqui cor mais chamativa e um glow para
/// saltar à vista.
class _UnclaimedFeesChip extends StatelessWidget {
  final double valueUsd;
  final CurrencyFormatter formatter;
  final AppPalette palette;

  const _UnclaimedFeesChip({
    required this.valueUsd,
    required this.formatter,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = palette.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '${formatter.format(valueUsd)} não reclamadas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Explicação do impermanent loss com um exemplo numérico concreto —
/// pedido do utilizador ("com exemplo visual"). Usa o caso clássico de o
/// preço duplicar, porque é o mais citado e fácil de verificar: ≈5.7% de
/// IL é o número que aparece em qualquer calculadora de IL para r=2.
class _ImpermanentLossExplainer extends StatelessWidget {
  const _ImpermanentLossExplainer();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fornecer liquidez obriga o teu capital a seguir a pool: quando o '
          'preço de um dos tokens sobe, a pool vende-o automaticamente a '
          'troco do outro — acabas com menos do token que subiu do que se '
          'tivesses só guardado os dois na carteira. Essa diferença é o '
          'impermanent loss. Quanto mais o preço se mover (em qualquer '
          'direção), maior o IL — e volta a 0% se o preço voltar ao sítio '
          'onde abriste a posição.',
          style: TextStyle(
            fontSize: 13,
            color: palette.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exemplo: investes \$1000 (50/50) e o preço de um dos '
                'tokens duplica',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _ComparisonBar(
                label: 'Se tivesses guardado (HODL)',
                valueLabel: '\$1118',
                fraction: 1.0,
                color: palette.textSecondary,
                palette: palette,
              ),
              const SizedBox(height: 8),
              _ComparisonBar(
                label: 'Fornecendo liquidez (sem contar as taxas)',
                valueLabel: '\$1054',
                fraction: 1054 / 1118,
                color: palette.warning,
                palette: palette,
              ),
              const SizedBox(height: 8),
              Text(
                '≈ 5.7% de impermanent loss — é por isto que as taxas '
                'geradas precisam de compensar esta diferença para a '
                'posição valer a pena.',
                style: TextStyle(fontSize: 11, color: palette.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double fraction;
  final Color color;
  final AppPalette palette;

  const _ComparisonBar({
    required this.label,
    required this.valueLabel,
    required this.fraction,
    required this.color,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: palette.textSecondary),
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 6,
            backgroundColor: palette.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends ConsumerWidget {
  final String positionKey;
  final CurrencyFormatter formatter;

  /// Para v4 isto fica SEMPRE vazio (não há subgraph a dar o histórico de
  /// mint/add/remove/collect, ver nota em `live_pool_fees_repository.dart`)
  /// — por isso o texto do estado vazio é diferente de v3, onde "ainda sem
  /// eventos" é genuíno (pode vir a preencher-se).
  final bool isV4;

  const _ActivitySection({
    required this.positionKey,
    required this.formatter,
    required this.isV4,
  });

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
          Row(
            children: [
              Text(
                'Atividade',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => showInfoSheet(
                  context,
                  title: 'Atividade',
                  body: const InfoSheetText(
                    'Histórico de mints, aumentos/diminuições de liquidez '
                    'e collects desta posição, com o hash da transação — '
                    'útil para confirmar quando e quanto foi depositado '
                    'ou retirado.\n\n'
                    'Só disponível para posições v3 (vem do subgraph). '
                    'Para v4 fica sempre vazio, não por falta de '
                    'eventos — não há uma fonte fiável para reconstruir '
                    'esse histórico sem arriscar números errados (ver '
                    'limitações do v4 nas Definições → Glossário).',
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 13,
                  color: palette.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          eventsAsync.when(
            data: (events) => events.isEmpty
                ? Text(
                    isV4
                        ? 'Não disponível para posições v4 (ver o ⓘ acima)'
                        : 'Ainda sem eventos',
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
              'Não foi possível carregar a atividade',
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

String _formatDuration(Duration d) {
  final days = d.inDays;
  final hours = d.inHours % 24;
  if (days > 0) return '${days}d ${hours}h';
  return '${d.inHours}h';
}

/// Card de aviso: quanto tempo a posição está fora do range, uma
/// estimativa de fees perdidas, e — se já durar o suficiente — uma
/// sugestão de novo range (sem executar nada on-chain).
class _OutOfRangeAdvisory extends StatelessWidget {
  final OutOfRangeEstimate estimate;
  final RebalanceSuggestion? rebalanceSuggestion;
  final PoolPosition position;
  final CurrencyFormatter formatter;

  const _OutOfRangeAdvisory({
    required this.estimate,
    required this.rebalanceSuggestion,
    required this.position,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final suggestion = rebalanceSuggestion;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: palette.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'Fora do range há ${_formatDuration(estimate.duration)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: palette.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '~${formatter.format(estimate.missedFeesUsd)} em taxas perdidas em relação '
            'à tua taxa habitual enquanto esteve fora do range — só uma estimativa, '
            'assume que a taxa anterior à saída do range se teria mantido.',
            style: TextStyle(fontSize: 11, color: palette.textSecondary),
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 10),
            Divider(color: palette.warning.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 10),
            Text(
              'Considera fazer rebalancing para '
              '${formatTokenPrice(priceAtTick(tick: suggestion.newTickLower, token0Decimals: position.token0Decimals, token1Decimals: position.token1Decimals))} – '
              '${formatTokenPrice(priceAtTick(tick: suggestion.newTickUpper, token0Decimals: position.token0Decimals, token1Decimals: position.token1Decimals))} '
              '${position.token1Symbol} por ${position.token0Symbol} '
              '(mesma largura, centrado no preço atual).',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Não é uma transação — rebalancing significa fechar esta posição e '
              'abrir uma nova, o que custa gas e pode gerar impermanent loss.',
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

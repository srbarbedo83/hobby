import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/bar_aggregator.dart';
import '../../core/calc/comparison_calc.dart';
import '../../core/calc/pool_metrics.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../../shared/widgets/segmented_pill_control.dart';
import '../../shared/widgets/token_pair_icon.dart';

/// Sobrepõe o histórico de fees de duas posições escolhidas pelo
/// utilizador, com as suas estatísticas principais lado a lado — para
/// comparar performance sem ter de alternar entre dois ecrãs de detalhe.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  String? _keyA;
  String? _keyB;
  ChartRange _range = ChartRange.last7d;
  ChartGroupBy _groupBy = ChartGroupBy.day;

  static const _colorA = Color(0xFFFF4FA3);
  static const _colorB = Color(0xFF4DD0E1);

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final positions =
        (ref.watch(positionsStreamProvider).value ?? const <PoolPosition>[])
            .where((p) => !p.isClosed)
            .toList();
    final snapshots =
        ref.watch(allFeeSnapshotsProvider).value ??
        const <String, List<FeeSnapshot>>{};
    final formatter = CurrencyFormatter(settings.currencyCode);

    _keyA ??= positions.isNotEmpty ? positions[0].positionKey : null;
    _keyB ??= positions.length > 1 ? positions[1].positionKey : null;

    final positionA = _findByKey(positions, _keyA);
    final positionB = _findByKey(positions, _keyB);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare pools')),
      body: SafeArea(
        child: positions.length < 2
            ? Center(
                child: Text(
                  'Need at least 2 open positions to compare',
                  style: TextStyle(color: palette.textSecondary),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _PositionPicker(
                          positions: positions,
                          selectedKey: _keyA,
                          accentColor: _colorA,
                          onChanged: (key) => setState(() => _keyA = key),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PositionPicker(
                          positions: positions,
                          selectedKey: _keyB,
                          accentColor: _colorB,
                          onChanged: (key) => setState(() => _keyB = key),
                        ),
                      ),
                    ],
                  ),
                  if (positionA != null && positionB != null) ...[
                    const SizedBox(height: 18),
                    SegmentedPillControl<ChartRange>(
                      options: ChartRange.values,
                      selected: _range,
                      labelBuilder: (r) => r.label,
                      onSelected: (r) => setState(() {
                        _range = r;
                        if (!r.allowedGroupBys.contains(_groupBy)) {
                          _groupBy = r.defaultGroupBy;
                        }
                      }),
                    ),
                    const SizedBox(height: 8),
                    SegmentedPillControl<ChartGroupBy>(
                      options: _range.allowedGroupBys,
                      selected: _groupBy,
                      labelBuilder: (g) => g.label,
                      onSelected: (g) => setState(() => _groupBy = g),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: palette.border),
                      ),
                      child: _ComparisonChart(
                        series: buildComparisonSeries(
                          snapshotsA:
                              snapshots[positionA.positionKey] ?? const [],
                          snapshotsB:
                              snapshots[positionB.positionKey] ?? const [],
                          range: _range,
                          groupBy: _groupBy,
                        ),
                        colorA: _colorA,
                        colorB: _colorB,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatComparisonRow(
                      positionA: positionA,
                      positionB: positionB,
                      snapshotsA: snapshots[positionA.positionKey] ?? const [],
                      snapshotsB: snapshots[positionB.positionKey] ?? const [],
                      formatter: formatter,
                      colorA: _colorA,
                      colorB: _colorB,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

PoolPosition? _findByKey(List<PoolPosition> positions, String? key) {
  if (key == null) return null;
  for (final p in positions) {
    if (p.positionKey == key) return p;
  }
  return null;
}

class _PositionPicker extends StatelessWidget {
  final List<PoolPosition> positions;
  final String? selectedKey;
  final Color accentColor;
  final ValueChanged<String?> onChanged;

  const _PositionPicker({
    required this.positions,
    required this.selectedKey,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedKey,
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      items: [
        for (final p in positions)
          DropdownMenuItem(
            value: p.positionKey,
            child: Text(
              '${p.token0Symbol} / ${p.token1Symbol}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final List<ComparisonPoint> series;
  final Color colorA;
  final Color colorB;

  const _ComparisonChart({
    required this.series,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (series.length < 2) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Not enough history yet',
            style: TextStyle(color: palette.textTertiary, fontSize: 12),
          ),
        ),
      );
    }

    final maxValue = series
        .expand((p) => [p.valueA, p.valueB])
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: (series.length / 4)
                    .clamp(1, series.length)
                    .toDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.round();
                  if (idx < 0 || idx >= series.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      series[idx].label,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < series.length; i++)
                  FlSpot(i.toDouble(), series[i].valueA),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              color: colorA,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: [
                for (var i = 0; i < series.length; i++)
                  FlSpot(i.toDouble(), series[i].valueB),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              color: colorB,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatComparisonRow extends StatelessWidget {
  final PoolPosition positionA;
  final PoolPosition positionB;
  final List<FeeSnapshot> snapshotsA;
  final List<FeeSnapshot> snapshotsB;
  final CurrencyFormatter formatter;
  final Color colorA;
  final Color colorB;

  const _StatComparisonRow({
    required this.positionA,
    required this.positionB,
    required this.snapshotsA,
    required this.snapshotsB,
    required this.formatter,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final metricsA = computePoolMetrics(
      position: positionA,
      snapshots: snapshotsA,
    );
    final metricsB = computePoolMetrics(
      position: positionB,
      snapshots: snapshotsB,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(flex: 2, child: SizedBox()),
              Expanded(
                child: _PairHeader(position: positionA, color: colorA),
              ),
              Expanded(
                child: _PairHeader(position: positionB, color: colorB),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StatRow(
            label: 'Lifetime fees',
            valueA: formatter.format(positionA.feesTotalUsd),
            valueB: formatter.format(positionB.feesTotalUsd),
          ),
          _StatRow(
            label: 'APR (7d)',
            valueA: '${metricsA.realizedAprPct.toStringAsFixed(1)}%',
            valueB: '${metricsB.realizedAprPct.toStringAsFixed(1)}%',
          ),
          _StatRow(
            label: 'Impermanent loss',
            valueA: '${metricsA.impermanentLoss.lossPct.toStringAsFixed(2)}%',
            valueB: '${metricsB.impermanentLoss.lossPct.toStringAsFixed(2)}%',
          ),
          _StatRow(
            label: 'Position value',
            valueA: formatter.format(positionA.liquidityUsd),
            valueB: formatter.format(positionB.liquidityUsd),
          ),
        ],
      ),
    );
  }
}

class _PairHeader extends StatelessWidget {
  final PoolPosition position;
  final Color color;

  const _PairHeader({required this.position, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TokenPairIcon(
          token0: position.token0Symbol,
          token1: position.token1Symbol,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          '${position.token0Symbol}/${position.token1Symbol}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String valueA;
  final String valueB;

  const _StatRow({
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              valueA,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valueB,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

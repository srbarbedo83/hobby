import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../calc/bar_aggregator.dart';
import '../calc/pool_metrics.dart';
import '../calc/range_health.dart';
import '../calc/univ3_fee_math.dart';
import '../format/currency_formatter.dart';

String _formatPrice(double price) =>
    price < 1 ? price.toStringAsFixed(6) : price.toStringAsFixed(2);

/// Gera um relatório PDF de uma página com o resumo de uma posição — para
/// quem quer um ficheiro para guardar ou enviar (contabilidade pessoal,
/// registo de uma venda/fecho), em vez do texto simples de
/// [buildPositionSummaryText] ou do CSV de histórico completo.
Future<List<int>> buildPositionReportPdf({
  required PoolPosition position,
  required PoolMetrics metrics,
  required CurrencyFormatter formatter,
  required DateTime generatedAt,

  /// Histórico de fees da posição, para o gráfico de "taxas por semana" —
  /// opcional (lista vazia omite a secção) para não obrigar quem só quer
  /// o resumo de números a ir buscar o histórico primeiro.
  List<FeeSnapshot> snapshots = const [],
}) async {
  final doc = pw.Document();
  final rangeLabel = switch (metrics.rangeHealth.status) {
    RangeStatus.inRange => 'Em range',
    RangeStatus.nearEdge => 'Perto da margem do range',
    RangeStatus.outOfRange => 'Fora do range',
  };
  final currentPrice = priceAtTick(
    tick: position.currentTick,
    token0Decimals: position.token0Decimals,
    token1Decimals: position.token1Decimals,
  );
  final weeklyBars = aggregateFeeSnapshots(
    snapshots: snapshots,
    range: ChartRange.last90d,
    groupBy: ChartGroupBy.week,
    now: generatedAt,
  );

  doc.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${position.token0Symbol} / ${position.token1Symbol}',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Pool Fees Tracker · relatório gerado em '
            '${generatedAt.day.toString().padLeft(2, '0')}/'
            '${generatedAt.month.toString().padLeft(2, '0')}/'
            '${generatedAt.year} · '
            '1 ${position.token0Symbol} = '
            '${_formatPrice(currentPrice)} ${position.token1Symbol}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          _row('Chain', position.chain.name),
          _row('Estado', rangeLabel),
          _row('Fee tier', '${position.feeTierPct.toStringAsFixed(2)}%'),
          _row('Dias aberta', '${metrics.sinceOpen.daysOpen}'),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _row(
            'Capital inicial',
            formatter.format(position.initialLiquidityUsd),
          ),
          _row(
            'Valor atual da posição',
            formatter.format(position.liquidityUsd),
          ),
          _row('Taxas reclamadas', formatter.format(position.feesClaimedUsd)),
          _row(
            'Taxas não reclamadas',
            formatter.format(position.feesUnclaimedUsd),
          ),
          _row(
            'Taxas totais (vitalícias)',
            formatter.format(position.feesTotalUsd),
          ),
          _row('Custo de gás', formatter.format(position.gasCostUsd)),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _row('APR (7d)', '${metrics.realizedAprPct.toStringAsFixed(1)}%'),
          _row(
            'Impermanent loss',
            '${metrics.impermanentLoss.lossPct.toStringAsFixed(2)}%',
          ),
          _row('Net vs. HODL', formatter.format(metrics.netVsHoldUsd)),
          _row(
            'Gas break-even',
            metrics.gasBreakEven.reached
                ? 'Pago'
                : formatter.format(metrics.gasBreakEven.remainingUsd),
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 12),
          pw.Text(
            'Previsão (tendência à taxa diária atual, não garantia)',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          _row(
            'Projeção este mês',
            formatter.format(metrics.projection.projectedEndOfMonthUsd),
          ),
          _row(
            'Projeção este ano',
            formatter.format(metrics.projection.projectedEndOfYearUsd),
          ),
          if (weeklyBars.length >= 2) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Taxas geradas por semana (últimos ~90 dias)',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _weeklyFeesChart(weeklyBars, formatter),
          ],
        ],
      ),
    ),
  );

  return doc.save();
}

pw.Widget _row(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

/// Barras simples desenhadas com `Container`s em vez do widget `Chart` do
/// pacote `pdf` — mais código, mas sem precisar de aprender a API de
/// grelhas/eixos desse widget só para um gráfico pequeno e sem interação.
pw.Widget _weeklyFeesChart(List<BarPoint> bars, CurrencyFormatter formatter) {
  final maxValue = bars.fold<double>(
    0,
    (a, b) => b.valueUsd > a ? b.valueUsd : a,
  );
  const chartHeight = 70.0;
  return pw.Container(
    height: chartHeight + 20,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        for (final bar in bars)
          pw.Expanded(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  bar.valueUsd > 0 ? formatter.formatCompact(bar.valueUsd) : '',
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Container(
                  height: maxValue <= 0
                      ? 1
                      : (chartHeight * (bar.valueUsd / maxValue)).clamp(
                          1,
                          chartHeight,
                        ),
                  margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.blue400,
                    borderRadius: pw.BorderRadius.vertical(
                      top: pw.Radius.circular(2),
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  bar.label,
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

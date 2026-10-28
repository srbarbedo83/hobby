import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/local/pool_position.dart';
import '../calc/pool_metrics.dart';
import '../calc/range_health.dart';
import '../format/currency_formatter.dart';

/// Gera um relatório PDF de uma página com o resumo de uma posição — para
/// quem quer um ficheiro para guardar ou enviar (contabilidade pessoal,
/// registo de uma venda/fecho), em vez do texto simples de
/// [buildPositionSummaryText] ou do CSV de histórico completo.
Future<List<int>> buildPositionReportPdf({
  required PoolPosition position,
  required PoolMetrics metrics,
  required CurrencyFormatter formatter,
  required DateTime generatedAt,
}) async {
  final doc = pw.Document();
  final rangeLabel = switch (metrics.rangeHealth.status) {
    RangeStatus.inRange => 'Em range',
    RangeStatus.nearEdge => 'Perto da margem do range',
    RangeStatus.outOfRange => 'Fora do range',
  };

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
            '${generatedAt.year}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
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

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/export/csv_export.dart';
import '../../core/export/position_pdf.dart';
import '../../core/calc/pool_metrics.dart';
import '../../core/format/currency_formatter.dart';
import '../local/fee_snapshot.dart';
import '../local/pool_position.dart';
import '../local/position_event.dart';

/// Escreve o histórico de fees + eventos de uma posição num CSV
/// temporário e abre o share sheet nativo (guardar, enviar por email,
/// Drive, etc.) — backup pessoal, não um documento fiscal.
class ExportService {
  static Future<void> shareFeeHistoryCsv({
    required String pairLabel,
    required List<FeeSnapshot> snapshots,
    required List<PositionEvent> events,
  }) async {
    final csv = StringBuffer()
      ..writeln('# Histórico de fees')
      ..writeln(buildFeeHistoryCsv(snapshots))
      ..writeln()
      ..writeln('# Eventos')
      ..writeln(buildEventsCsv(events));

    final dir = await getTemporaryDirectory();
    final safeLabel = pairLabel.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final file = File('${dir.path}/pool_fees_$safeLabel.csv');
    await file.writeAsString(csv.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Histórico de fees — $pairLabel',
      ),
    );
  }

  /// Partilha um resumo em texto da performance de uma posição — sem
  /// ficheiros, só para colar numa mensagem/post.
  static Future<void> sharePositionSummary(String summary) async {
    await SharePlus.instance.share(ShareParams(text: summary));
  }

  /// Gera e partilha um relatório PDF de uma posição — para quem quer um
  /// ficheiro para guardar (registo pessoal, não um documento fiscal).
  static Future<void> sharePositionReportPdf({
    required PoolPosition position,
    required PoolMetrics metrics,
    required CurrencyFormatter formatter,
    List<FeeSnapshot> snapshots = const [],
  }) async {
    final bytes = await buildPositionReportPdf(
      position: position,
      metrics: metrics,
      formatter: formatter,
      generatedAt: DateTime.now(),
      snapshots: snapshots,
    );

    final dir = await getTemporaryDirectory();
    final safeLabel = '${position.token0Symbol}_${position.token1Symbol}'
        .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    final file = File('${dir.path}/pool_fees_$safeLabel.pdf');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject:
            'Relatório — ${position.token0Symbol}/${position.token1Symbol}',
      ),
    );
  }

  /// Partilha o backup de definições/carteiras como ficheiro .json — para
  /// guardar nas Notas, Drive, etc. e colar de volta mais tarde no ecrã de
  /// Definições para restaurar.
  static Future<void> shareSettingsBackup(String json) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pool_fees_tracker_backup.json');
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Backup — Pool Fees Tracker',
      ),
    );
  }
}

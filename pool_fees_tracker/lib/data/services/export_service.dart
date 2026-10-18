import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/export/csv_export.dart';
import '../local/fee_snapshot.dart';
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

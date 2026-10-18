import '../../data/local/fee_snapshot.dart';
import '../../data/local/position_event.dart';

/// Escapa um valor para uma célula CSV (RFC 4180): só precisa de aspas se
/// tiver vírgula, aspas ou quebra de linha.
String _csvCell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _csvRow(List<String> cells) => cells.map(_csvCell).join(',');

/// CSV do histórico de fees de uma posição — um ponto por linha, para
/// backup pessoal (não é um documento fiscal).
String buildFeeHistoryCsv(List<FeeSnapshot> snapshots) {
  final lines = [
    _csvRow(['timestamp', 'fees_usd_delta']),
    for (final s in snapshots)
      _csvRow([s.timestamp.toIso8601String(), s.feesUsdDelta.toString()]),
  ];
  return lines.join('\n');
}

/// CSV do histórico de eventos (mint/collect/adds/removes) de uma posição.
String buildEventsCsv(List<PositionEvent> events) {
  final lines = [
    _csvRow(['timestamp', 'type', 'amount_usd', 'tx_hash']),
    for (final e in events)
      _csvRow([
        e.timestamp.toIso8601String(),
        e.type.name,
        e.amountUsd.toString(),
        e.txHash ?? '',
      ]),
  ];
  return lines.join('\n');
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/export/csv_export.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/position_event.dart';

void main() {
  group('buildFeeHistoryCsv', () {
    test('escreve o cabeçalho e uma linha por snapshot', () {
      final snapshots = [
        FeeSnapshot()
          ..positionKey = 'p1'
          ..timestamp = DateTime.utc(2026, 1, 1)
          ..feesUsdDelta = 1.5,
      ];
      final csv = buildFeeHistoryCsv(snapshots);
      final lines = csv.split('\n');
      expect(lines[0], 'timestamp,fees_usd_delta');
      expect(lines[1], '2026-01-01T00:00:00.000Z,1.5');
    });

    test('lista vazia dá só o cabeçalho', () {
      expect(buildFeeHistoryCsv(const []), 'timestamp,fees_usd_delta');
    });
  });

  group('buildEventsCsv', () {
    test(
      'escreve o cabeçalho e uma linha por evento, com txHash vazio se null',
      () {
        final events = [
          PositionEvent()
            ..positionKey = 'p1'
            ..timestamp = DateTime.utc(2026, 1, 1)
            ..type = PositionEventType.mint
            ..amountUsd = 100.0
            ..txHash = null,
        ];
        final csv = buildEventsCsv(events);
        final lines = csv.split('\n');
        expect(lines[0], 'timestamp,type,amount_usd,tx_hash');
        expect(lines[1], '2026-01-01T00:00:00.000Z,mint,100.0,');
      },
    );

    test('escapa vírgulas e aspas nos campos', () {
      final events = [
        PositionEvent()
          ..positionKey = 'p1'
          ..timestamp = DateTime.utc(2026, 1, 1)
          ..type = PositionEventType.collect
          ..amountUsd = 5.0
          ..txHash = '0xabc,"weird"',
      ];
      final csv = buildEventsCsv(events);
      expect(csv, contains('"0xabc,""weird"""'));
    });
  });
}

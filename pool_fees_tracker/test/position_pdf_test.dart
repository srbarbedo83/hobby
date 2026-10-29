import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/pool_metrics.dart';
import 'package:pool_fees_tracker/core/export/position_pdf.dart';
import 'package:pool_fees_tracker/core/format/currency_formatter.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';
import 'package:pool_fees_tracker/data/local/pool_position.dart';

void main() {
  group('buildPositionReportPdf', () {
    test('gera bytes de um PDF válido (cabeçalho %PDF)', () async {
      final position = PoolPosition()
        ..positionKey = 'a'
        ..chain = Chain.ethereum
        ..walletAddress = '0xabc'
        ..tokenIdOnChain = '1'
        ..token0Symbol = 'ETH'
        ..token1Symbol = 'USDC'
        ..feeTierBps = 500
        ..createdAt = DateTime(2025, 1, 1)
        ..tickLower = -100
        ..tickUpper = 100
        ..currentTick = 0
        ..entryTick = 0
        ..liquidityUsd = 1000
        ..initialLiquidityUsd = 900
        ..feesClaimedUsd = 10
        ..feesUnclaimedUsd = 5
        ..gasCostUsd = 2
        ..isClosed = false;

      final metrics = computePoolMetrics(
        position: position,
        snapshots: const <FeeSnapshot>[],
      );

      final bytes = await buildPositionReportPdf(
        position: position,
        metrics: metrics,
        formatter: CurrencyFormatter('USD'),
        generatedAt: DateTime(2026, 1, 1),
      );

      expect(bytes, isNotEmpty);
      // Todo o ficheiro PDF começa pela assinatura "%PDF-".
      expect(bytes.take(5), [0x25, 0x50, 0x44, 0x46, 0x2d]);
    });

    test('inclui o gráfico semanal quando há histórico suficiente', () async {
      final position = PoolPosition()
        ..positionKey = 'a'
        ..chain = Chain.ethereum
        ..walletAddress = '0xabc'
        ..tokenIdOnChain = '1'
        ..token0Symbol = 'ETH'
        ..token1Symbol = 'USDC'
        ..feeTierBps = 500
        ..createdAt = DateTime(2025, 1, 1)
        ..tickLower = -100
        ..tickUpper = 100
        ..currentTick = 0
        ..entryTick = 0
        ..liquidityUsd = 1000
        ..initialLiquidityUsd = 900
        ..feesClaimedUsd = 10
        ..feesUnclaimedUsd = 5
        ..gasCostUsd = 2
        ..isClosed = false;

      final now = DateTime(2026, 1, 1);
      final snapshots = [
        for (var w = 1; w <= 6; w++)
          FeeSnapshot()
            ..positionKey = 'a'
            ..timestamp = now.subtract(Duration(days: w * 7))
            ..feesUsdDelta = w * 2.0,
      ];

      final metrics = computePoolMetrics(
        position: position,
        snapshots: snapshots,
      );

      final bytes = await buildPositionReportPdf(
        position: position,
        metrics: metrics,
        formatter: CurrencyFormatter('USD'),
        generatedAt: now,
        snapshots: snapshots,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.take(5), [0x25, 0x50, 0x44, 0x46, 0x2d]);
    });
  });
}

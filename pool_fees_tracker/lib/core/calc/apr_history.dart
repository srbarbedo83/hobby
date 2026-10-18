import '../../data/local/fee_snapshot.dart';
import 'apr_calculator.dart';
import 'bar_aggregator.dart';

class AprPoint {
  final DateTime bucketStart;
  final String label;
  final double aprPct;

  const AprPoint({
    required this.bucketStart,
    required this.label,
    required this.aprPct,
  });
}

double _periodDaysFor(ChartGroupBy groupBy) => switch (groupBy) {
  ChartGroupBy.hour => 1 / 24,
  ChartGroupBy.day => 1,
  ChartGroupBy.week => 7,
  ChartGroupBy.month => 30,
};

/// Agrega os fees da posição em barras (como [aggregateFeeSnapshots]) e
/// converte cada barra na APR anualizada implícita nesse período, usando a
/// liquidez atual da posição — mostra como a taxa de retorno realizada
/// evoluiu ao longo do tempo, em vez de só um número médio.
///
/// Usa a liquidez ATUAL para todas as barras (não há histórico de liquidez
/// por posição), por isso uma mudança grande e recente de liquidez distorce
/// a leitura das barras mais antigas — uma aproximação aceitável para uma
/// leitura de tendência, não um valor de precisão contabilística.
List<AprPoint> computeAprHistory({
  required List<FeeSnapshot> snapshots,
  required double liquidityUsd,
  required ChartRange range,
  required ChartGroupBy groupBy,
  DateTime? now,
}) {
  final bars = aggregateFeeSnapshots(
    snapshots: snapshots,
    range: range,
    groupBy: groupBy,
    now: now,
  );
  final periodDays = _periodDaysFor(groupBy);
  return [
    for (final bar in bars)
      AprPoint(
        bucketStart: bar.bucketStart,
        label: bar.label,
        aprPct: realizedAprPct(
          feesUsdEarnedInPeriod: bar.valueUsd,
          liquidityUsd: liquidityUsd,
          periodDays: periodDays,
        ),
      ),
  ];
}

import '../../data/local/pool_position.dart';
import '../calc/pool_metrics.dart';
import '../calc/range_health.dart';
import '../format/currency_formatter.dart';

/// Resumo em texto simples da performance de uma posição — para partilhar
/// num share sheet (mensagem, post, etc.), sem precisar de um ficheiro.
String buildPositionSummaryText({
  required PoolPosition position,
  required PoolMetrics metrics,
  required CurrencyFormatter formatter,
}) {
  final rangeLabel = switch (metrics.rangeHealth.status) {
    RangeStatus.inRange => 'em range',
    RangeStatus.nearEdge => 'perto da margem do range',
    RangeStatus.outOfRange => 'fora do range',
  };
  return '${position.token0Symbol}/${position.token1Symbol} no Pool Fees Tracker\n'
      '${formatter.format(position.feesTotalUsd)} em taxas ganhas '
      '(${metrics.sinceOpen.daysOpen}d aberta)\n'
      'APR (7d): ${metrics.realizedAprPct.toStringAsFixed(1)}%\n'
      'Atualmente $rangeLabel';
}

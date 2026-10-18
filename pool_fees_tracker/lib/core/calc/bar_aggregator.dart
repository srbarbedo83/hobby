import 'package:intl/intl.dart';

import '../../data/local/fee_snapshot.dart';

enum ChartGroupBy { hour, day, week, month }

enum ChartRange { last24h, last7d, last30d, last90d, allTime }

extension ChartRangeInfo on ChartRange {
  String get label => switch (this) {
    ChartRange.last24h => '24H',
    ChartRange.last7d => '7D',
    ChartRange.last30d => '30D',
    ChartRange.last90d => '90D',
    ChartRange.allTime => 'ALL',
  };

  Duration? get lookback => switch (this) {
    ChartRange.last24h => const Duration(hours: 24),
    ChartRange.last7d => const Duration(days: 7),
    ChartRange.last30d => const Duration(days: 30),
    ChartRange.last90d => const Duration(days: 90),
    ChartRange.allTime => null,
  };

  /// Agrupamento por omissão sugerido para este intervalo (o utilizador pode
  /// escolher outro, de entre [allowedGroupBys], no segmented control de
  /// "Agrupar por").
  ChartGroupBy get defaultGroupBy => switch (this) {
    ChartRange.last24h => ChartGroupBy.hour,
    ChartRange.last7d => ChartGroupBy.day,
    ChartRange.last30d => ChartGroupBy.day,
    ChartRange.last90d => ChartGroupBy.week,
    ChartRange.allTime => ChartGroupBy.month,
  };

  /// Agrupamentos que fazem sentido para este intervalo — evita, por
  /// exemplo, pedir barras por hora ao longo de "Desde o início".
  List<ChartGroupBy> get allowedGroupBys => switch (this) {
    ChartRange.last24h => const [ChartGroupBy.hour],
    ChartRange.last7d => const [ChartGroupBy.hour, ChartGroupBy.day],
    ChartRange.last30d => const [ChartGroupBy.day, ChartGroupBy.week],
    ChartRange.last90d => const [ChartGroupBy.week, ChartGroupBy.month],
    ChartRange.allTime => const [ChartGroupBy.month],
  };
}

extension ChartGroupByInfo on ChartGroupBy {
  String get label => switch (this) {
    ChartGroupBy.hour => 'Hour',
    ChartGroupBy.day => 'Day',
    ChartGroupBy.week => 'Week',
    ChartGroupBy.month => 'Month',
  };
}

class BarPoint {
  final DateTime bucketStart;
  final String label;
  final double valueUsd;

  const BarPoint({
    required this.bucketStart,
    required this.label,
    required this.valueUsd,
  });
}

DateTime _bucketStart(DateTime t, ChartGroupBy groupBy) {
  switch (groupBy) {
    case ChartGroupBy.hour:
      return DateTime(t.year, t.month, t.day, t.hour);
    case ChartGroupBy.day:
      return DateTime(t.year, t.month, t.day);
    case ChartGroupBy.week:
      final monday = t.subtract(Duration(days: t.weekday - 1));
      return DateTime(monday.year, monday.month, monday.day);
    case ChartGroupBy.month:
      return DateTime(t.year, t.month);
  }
}

String _bucketLabel(DateTime t, ChartGroupBy groupBy) {
  switch (groupBy) {
    case ChartGroupBy.hour:
      return DateFormat.Hm().format(t);
    case ChartGroupBy.day:
      return DateFormat.E().format(t);
    case ChartGroupBy.week:
      return 'W${_isoWeekOfYear(t)}';
    case ChartGroupBy.month:
      return DateFormat.MMM().format(t);
  }
}

int _isoWeekOfYear(DateTime date) {
  final dayOfYear = int.parse(DateFormat('D').format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

/// Agrega os deltas de fees de uma posição no intervalo [range], juntando-os
/// em barras por [groupBy]. Os snapshots devem já pertencer a uma única
/// posição (filtrados por `positionKey` antes de chegar aqui).
List<BarPoint> aggregateFeeSnapshots({
  required List<FeeSnapshot> snapshots,
  required ChartRange range,
  required ChartGroupBy groupBy,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final lookback = range.lookback;
  final cutoff = lookback == null ? null : effectiveNow.subtract(lookback);

  final buckets = <DateTime, double>{};
  for (final s in snapshots) {
    if (cutoff != null && s.timestamp.isBefore(cutoff)) continue;
    final key = _bucketStart(s.timestamp, groupBy);
    buckets[key] = (buckets[key] ?? 0) + s.feesUsdDelta;
  }

  final sortedKeys = buckets.keys.toList()..sort();
  return [
    for (final k in sortedKeys)
      BarPoint(
        bucketStart: k,
        label: _bucketLabel(k, groupBy),
        valueUsd: buckets[k]!,
      ),
  ];
}

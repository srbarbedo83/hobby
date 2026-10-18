import 'package:intl/intl.dart';

import '../../data/local/price_point.dart';
import 'bar_aggregator.dart';

bool _isInRange(num tick, int tickLower, int tickUpper) =>
    tick >= tickLower && tick <= tickUpper;

class PricePathPoint {
  final DateTime bucketStart;
  final String label;

  /// Média dos ticks nesta bucket — pode ser fracionário (ex.: `-201042.6`)
  /// porque é uma média, não um tick real da pool; serve só para desenhar
  /// uma linha suave, não para matemática on-chain.
  final double avgTick;

  const PricePathPoint({
    required this.bucketStart,
    required this.label,
    required this.avgTick,
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

String _bucketLabel(DateTime t, ChartGroupBy groupBy) => switch (groupBy) {
  ChartGroupBy.hour => DateFormat.Hm().format(t),
  ChartGroupBy.day => DateFormat.E().format(t),
  ChartGroupBy.week => DateFormat.Md().format(t),
  ChartGroupBy.month => DateFormat.MMM().format(t),
};

/// Agrega o histórico de tick de uma posição em buckets de tempo, para
/// desenhar o gráfico preço-vs-range — mesma lógica de bucketing que
/// [aggregateFeeSnapshots], só a média do tick em vez da soma das fees.
List<PricePathPoint> aggregatePricePoints({
  required List<PricePoint> points,
  required ChartRange range,
  required ChartGroupBy groupBy,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final lookback = range.lookback;
  final cutoff = lookback == null ? null : effectiveNow.subtract(lookback);

  final sums = <DateTime, double>{};
  final counts = <DateTime, int>{};
  for (final p in points) {
    if (cutoff != null && p.timestamp.isBefore(cutoff)) continue;
    final key = _bucketStart(p.timestamp, groupBy);
    sums[key] = (sums[key] ?? 0) + p.tick;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final sortedKeys = sums.keys.toList()..sort();
  return [
    for (final k in sortedKeys)
      PricePathPoint(
        bucketStart: k,
        label: _bucketLabel(k, groupBy),
        avgTick: sums[k]! / counts[k]!,
      ),
  ];
}

/// Há quanto tempo a posição está continuamente fora do range, terminando
/// agora — `null` se o ponto mais recente já está dentro do range (ou não
/// há histórico). Aproximação: o início da sequência é o timestamp do
/// primeiro ponto já fora do range encontrado a andar para trás — se toda
/// a história conhecida já estava fora do range, subestima a duração real
/// (não sabe quando começou antes do primeiro ponto gravado).
Duration? currentOutOfRangeDuration({
  required List<PricePoint> points,
  required int tickLower,
  required int tickUpper,
  DateTime? now,
}) {
  if (points.isEmpty) return null;
  final sorted = [...points]
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  if (_isInRange(sorted.last.tick, tickLower, tickUpper)) return null;

  var streakStart = sorted.last.timestamp;
  for (var i = sorted.length - 1; i >= 0; i--) {
    if (_isInRange(sorted[i].tick, tickLower, tickUpper)) break;
    streakStart = sorted[i].timestamp;
  }
  return (now ?? DateTime.now()).difference(streakStart);
}

/// Streak atual (dias consecutivos terminando hoje, dentro do range) e o
/// maior streak já visto no histórico conhecido. Um dia conta como "dentro
/// do range" só se TODOS os pontos gravados nesse dia estavam dentro — um
/// único ponto fora do range nesse dia já conta o dia como fora.
({int current, int longest}) inRangeStreakDays({
  required List<PricePoint> points,
  required int tickLower,
  required int tickUpper,
  DateTime? now,
}) {
  if (points.isEmpty) return (current: 0, longest: 0);

  final inRangeByDay = <DateTime, bool>{};
  for (final p in points) {
    final day = DateTime(p.timestamp.year, p.timestamp.month, p.timestamp.day);
    final inRange = _isInRange(p.tick, tickLower, tickUpper);
    inRangeByDay[day] = (inRangeByDay[day] ?? true) && inRange;
  }

  final sortedDays = inRangeByDay.keys.toList()..sort();

  var longest = 0;
  var running = 0;
  for (final day in sortedDays) {
    if (inRangeByDay[day]!) {
      running += 1;
      if (running > longest) longest = running;
    } else {
      running = 0;
    }
  }

  var current = 0;
  for (var i = sortedDays.length - 1; i >= 0; i--) {
    if (!inRangeByDay[sortedDays[i]]!) break;
    current += 1;
  }

  final effectiveNow = now ?? DateTime.now();
  final today = DateTime(
    effectiveNow.year,
    effectiveNow.month,
    effectiveNow.day,
  );
  final lastKnownDay = sortedDays.last;
  // Se o último ponto conhecido não é de hoje (dados antigos, ou posição
  // Live que ainda não refrescou hoje), o streak "atual" não se pode
  // confirmar até hoje — conta-se só até ao último dia conhecido.
  if (lastKnownDay.isBefore(today) && !inRangeByDay[lastKnownDay]!) {
    current = 0;
  }

  return (current: current, longest: longest);
}

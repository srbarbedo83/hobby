import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import '../format/currency_formatter.dart';
import 'dashboard_metrics.dart';
import 'leaderboard.dart';

class WeeklyDigest {
  final double feesLast7dUsd;
  final double avgAprPct;
  final LeaderboardEntry? bestApr;

  const WeeklyDigest({
    required this.feesLast7dUsd,
    required this.avgAprPct,
    required this.bestApr,
  });
}

/// Resumo semanal do portefólio — fees da última semana, APR médio, e a
/// pool com melhor APR (se houver mais que uma posição aberta).
WeeklyDigest computeWeeklyDigest({
  required List<PoolPosition> positions,
  required Map<String, List<FeeSnapshot>> snapshotsByKey,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final cutoff = effectiveNow.subtract(const Duration(days: 7));

  var feesLast7d = 0.0;
  for (final position in positions) {
    for (final s in snapshotsByKey[position.positionKey] ?? const []) {
      if (s.timestamp.isAfter(cutoff)) feesLast7d += s.feesUsdDelta;
    }
  }

  final metrics = computeDashboardMetrics(
    positions: positions,
    snapshotsByKey: snapshotsByKey,
    now: effectiveNow,
  );
  final leaderboard = computeLeaderboard(
    positions: positions,
    snapshotsByKey: snapshotsByKey,
  );

  return WeeklyDigest(
    feesLast7dUsd: feesLast7d,
    avgAprPct: metrics.avgAprPct,
    bestApr: leaderboard.bestApr,
  );
}

/// Verdadeiro se nunca foi enviado, ou se já passou pelo menos uma semana
/// desde o último envio — comparado em dias inteiros, não em segundos, para
/// não depender de a verificação em background correr exatamente à mesma
/// hora todas as semanas.
bool shouldSendWeeklyDigest({required DateTime? lastSentAt, DateTime? now}) {
  if (lastSentAt == null) return true;
  final effectiveNow = now ?? DateTime.now();
  return effectiveNow.difference(lastSentAt).inDays >= 7;
}

String buildWeeklyDigestBody(WeeklyDigest digest, CurrencyFormatter formatter) {
  final best = digest.bestApr;
  final bestLine = best == null
      ? ''
      : ' · Melhor pool: ${best.position.token0Symbol}/${best.position.token1Symbol} '
            '(${best.aprPct.toStringAsFixed(1)}% APR)';
  return '${formatter.format(digest.feesLast7dUsd)} em taxas esta semana · '
      'APR médio ${digest.avgAprPct.toStringAsFixed(1)}%$bestLine';
}

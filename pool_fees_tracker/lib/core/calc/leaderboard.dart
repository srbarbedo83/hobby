import '../../data/local/fee_snapshot.dart';
import '../../data/local/pool_position.dart';
import 'pool_metrics.dart';

class LeaderboardEntry {
  final PoolPosition position;
  final double aprPct;
  final double ilLossPct;

  const LeaderboardEntry({
    required this.position,
    required this.aprPct,
    required this.ilLossPct,
  });
}

/// Melhor e pior posição ABERTA, por APR realizada (7d) e por impermanent
/// loss, respetivamente — um resumo rápido de "o que está a compensar"
/// sem ter de abrir pool a pool. Posições fechadas ficam de fora: já não
/// têm range/APR com sentido.
({LeaderboardEntry? bestApr, LeaderboardEntry? worstIl}) computeLeaderboard({
  required List<PoolPosition> positions,
  required Map<String, List<FeeSnapshot>> snapshotsByKey,
  DateTime? now,
}) {
  final openPositions = positions.where((p) => !p.isClosed).toList();
  if (openPositions.isEmpty) return (bestApr: null, worstIl: null);

  final entries = [
    for (final position in openPositions)
      () {
        final metrics = computePoolMetrics(
          position: position,
          snapshots: snapshotsByKey[position.positionKey] ?? const [],
          now: now,
        );
        return LeaderboardEntry(
          position: position,
          aprPct: metrics.realizedAprPct,
          ilLossPct: metrics.impermanentLoss.lossPct,
        );
      }(),
  ];

  final bestApr = entries.reduce((a, b) => b.aprPct > a.aprPct ? b : a);
  final worstIl = entries.reduce((a, b) => b.ilLossPct < a.ilLossPct ? b : a);

  return (bestApr: bestApr, worstIl: worstIl);
}

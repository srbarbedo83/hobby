import '../../data/local/fee_snapshot.dart';
import 'range_health.dart';

/// Score único 0-100 que combina três sinais já calculados noutro sítio
/// (range health, tendência de fees, impermanent loss) — para avaliar uma
/// posição num piscar de olhos, sem abrir o ecrã de detalhe. É uma
/// heurística simples (média dos três), não um indicador financeiro
/// rigoroso.
class PoolHealthScore {
  final int score;
  final int rangeScore;
  final int feeTrendScore;
  final int ilScore;

  const PoolHealthScore({
    required this.score,
    required this.rangeScore,
    required this.feeTrendScore,
    required this.ilScore,
  });
}

PoolHealthScore computePoolHealthScore({
  required RangeStatus rangeStatus,
  required List<FeeSnapshot> snapshots,
  required double impermanentLossPct,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final last24hCutoff = effectiveNow.subtract(const Duration(hours: 24));
  final last7dCutoff = effectiveNow.subtract(const Duration(days: 7));
  final fees24h = snapshots
      .where((s) => s.timestamp.isAfter(last24hCutoff))
      .fold<double>(0, (a, b) => a + b.feesUsdDelta);
  final fees7dAvgDaily =
      snapshots
          .where((s) => s.timestamp.isAfter(last7dCutoff))
          .fold<double>(0, (a, b) => a + b.feesUsdDelta) /
      7;

  final rangeScore = switch (rangeStatus) {
    RangeStatus.inRange => 100,
    RangeStatus.nearEdge => 60,
    RangeStatus.outOfRange => 0,
  };

  // Sem média de base, não há como avaliar a tendência — fica neutro
  // (50) em vez de penalizar uma posição só por ser nova.
  final feeTrendScore = fees7dAvgDaily <= 0.01
      ? 50
      : (fees24h / fees7dAvgDaily * 50).clamp(0, 100).round();

  final ilScore = (100 + impermanentLossPct * 10).clamp(0, 100).round();

  final score = ((rangeScore + feeTrendScore + ilScore) / 3).round();
  return PoolHealthScore(
    score: score,
    rangeScore: rangeScore,
    feeTrendScore: feeTrendScore,
    ilScore: ilScore,
  );
}

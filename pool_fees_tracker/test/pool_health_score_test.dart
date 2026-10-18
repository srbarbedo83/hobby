import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/pool_health_score.dart';
import 'package:pool_fees_tracker/core/calc/range_health.dart';
import 'package:pool_fees_tracker/data/local/fee_snapshot.dart';

FeeSnapshot _snap(DateTime t, double delta) {
  return FeeSnapshot()
    ..positionKey = 'p1'
    ..timestamp = t
    ..feesUsdDelta = delta;
}

void main() {
  final now = DateTime(2026, 2, 1, 12);

  test('tudo perfeito dá 100: em range, taxa normal, sem IL', () {
    final snapshots = [
      for (var d = 1; d <= 7; d++) _snap(now.subtract(Duration(days: d)), 14),
      _snap(now.subtract(const Duration(hours: 12)), 14),
    ];
    final result = computePoolHealthScore(
      rangeStatus: RangeStatus.inRange,
      snapshots: snapshots,
      impermanentLossPct: 0,
      now: now,
    );
    expect(result.rangeScore, 100);
    expect(result.feeTrendScore, 50);
    expect(result.ilScore, 100);
    expect(result.score, 83);
  });

  test('fora do range penaliza bastante o score total', () {
    final inRange = computePoolHealthScore(
      rangeStatus: RangeStatus.inRange,
      snapshots: const [],
      impermanentLossPct: 0,
      now: now,
    );
    final outOfRange = computePoolHealthScore(
      rangeStatus: RangeStatus.outOfRange,
      snapshots: const [],
      impermanentLossPct: 0,
      now: now,
    );
    expect(outOfRange.score, lessThan(inRange.score));
  });

  test('sem histórico de fees fica neutro (50), não penaliza', () {
    final result = computePoolHealthScore(
      rangeStatus: RangeStatus.inRange,
      snapshots: const [],
      impermanentLossPct: 0,
      now: now,
    );
    expect(result.feeTrendScore, 50);
  });

  test('IL grande reduz o ilScore até 0', () {
    final result = computePoolHealthScore(
      rangeStatus: RangeStatus.inRange,
      snapshots: const [],
      impermanentLossPct: -15,
      now: now,
    );
    expect(result.ilScore, 0);
  });
}

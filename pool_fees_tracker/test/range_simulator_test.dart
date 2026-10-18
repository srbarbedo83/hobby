import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/range_simulator.dart';
import 'package:pool_fees_tracker/data/local/price_point.dart';

PricePoint _point(int tick) => PricePoint()
  ..positionKey = 'p1'
  ..timestamp = DateTime(2026, 1, 1)
  ..tick = tick;

void main() {
  test('o range real (multiplier 1.0) tem score relativo exatamente 1.0', () {
    final points = [for (var t = -50; t <= 50; t += 10) _point(t)];
    final results = simulateRangeWidths(
      pricePoints: points,
      actualTickLower: -50,
      actualTickUpper: 50,
      entryTick: 0,
    );
    final baseline = results.firstWhere((r) => r.widthMultiplier == 1.0);
    expect(baseline.relativeFeeScore, closeTo(1.0, 1e-9));
  });

  test('um range mais estreito fica fora do range mais vezes', () {
    // Preço sempre em -80 ou 80 — fora de um range estreito (±25), dentro
    // de um largo (±100).
    final points = [for (var i = 0; i < 10; i++) _point(i.isEven ? -80 : 80)];
    final results = simulateRangeWidths(
      pricePoints: points,
      actualTickLower: -100,
      actualTickUpper: 100, // halfWidth real = 100
      entryTick: 0,
    );
    final narrow = results.firstWhere(
      (r) => r.widthMultiplier == 0.25,
    ); // halfWidth 25
    final wide = results.firstWhere(
      (r) => r.widthMultiplier == 1.0,
    ); // halfWidth 100
    expect(narrow.fractionInRange, 0.0);
    expect(wide.fractionInRange, 1.0);
  });

  test(
    'range inválido (largura real 0) ou histórico vazio devolve lista vazia',
    () {
      expect(
        simulateRangeWidths(
          pricePoints: const [],
          actualTickLower: -10,
          actualTickUpper: 10,
          entryTick: 0,
        ),
        isEmpty,
      );
      expect(
        simulateRangeWidths(
          pricePoints: [_point(0)],
          actualTickLower: 10,
          actualTickUpper: 10,
          entryTick: 0,
        ),
        isEmpty,
      );
    },
  );
}

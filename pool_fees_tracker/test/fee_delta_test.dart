import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/fee_delta.dart';

void main() {
  group('clampFeeDeltaUsd', () {
    test('sem total anterior (primeira vez) dá 0, não o total acumulado', () {
      expect(clampFeeDeltaUsd(previousTotal: null, currentTotal: 500), 0);
    });

    test('delta normal (total subiu) passa tal como está', () {
      expect(clampFeeDeltaUsd(previousTotal: 100, currentTotal: 112.5), 12.5);
    });

    test('delta negativo (ex.: revalorização do unclaimed) é cortado a 0', () {
      expect(clampFeeDeltaUsd(previousTotal: 100, currentTotal: 97.3), 0);
    });

    test('total igual ao anterior dá delta 0', () {
      expect(clampFeeDeltaUsd(previousTotal: 50, currentTotal: 50), 0);
    });
  });
}

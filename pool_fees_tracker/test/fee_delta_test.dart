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

  group('preservedV4FeesClaimedUsd', () {
    test('posição nova (sem total anterior) não credita nada', () {
      expect(
        preservedV4FeesClaimedUsd(previousTotalUsd: 0, currentUnclaimedUsd: 15),
        0,
      );
    });

    test('unclaimed a crescer normalmente não credita nada em claimed', () {
      expect(
        preservedV4FeesClaimedUsd(
          previousTotalUsd: 100,
          currentUnclaimedUsd: 120,
        ),
        0,
      );
    });

    test('collect() feito fora da app (unclaimed reseta) preserva o total '
        'vitalício em claimed', () {
      final claimed = preservedV4FeesClaimedUsd(
        previousTotalUsd: 100,
        currentUnclaimedUsd: 0.5,
      );
      expect(claimed, 99.5);
      // feesTotalUsd resultante (claimed + unclaimed) nunca desce.
      expect(claimed + 0.5, 100);
    });

    test('pequena revalorização de preço (unclaimed desce um pouco) também '
        'é absorvida, não só um collect completo', () {
      final claimed = preservedV4FeesClaimedUsd(
        previousTotalUsd: 100,
        currentUnclaimedUsd: 97.3,
      );
      expect(claimed, closeTo(2.7, 1e-9));
      expect(claimed + 97.3, 100);
    });
  });
}

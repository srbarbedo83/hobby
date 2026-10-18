import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/apr_calculator.dart';

void main() {
  group('realizedAprPct', () {
    test('anualiza um retorno de 7 dias', () {
      // 70 USD em 7 dias sobre 10000 USD de liquidez = 0.7%/semana,
      // anualizado (×365/7) ≈ 36.5%.
      final apr = realizedAprPct(
        feesUsdEarnedInPeriod: 70,
        liquidityUsd: 10000,
        periodDays: 7,
      );
      expect(apr, closeTo(36.5, 0.01));
    });

    test('devolve 0 com liquidez zero ou negativa', () {
      expect(
        realizedAprPct(
          feesUsdEarnedInPeriod: 10,
          liquidityUsd: 0,
          periodDays: 7,
        ),
        0,
      );
      expect(
        realizedAprPct(
          feesUsdEarnedInPeriod: 10,
          liquidityUsd: -5,
          periodDays: 7,
        ),
        0,
      );
    });

    test('devolve 0 com período zero ou negativo', () {
      expect(
        realizedAprPct(
          feesUsdEarnedInPeriod: 10,
          liquidityUsd: 1000,
          periodDays: 0,
        ),
        0,
      );
    });

    test(
      'fees negativas (ex.: posição recém-criada) dão APR negativo, não erro',
      () {
        final apr = realizedAprPct(
          feesUsdEarnedInPeriod: -5,
          liquidityUsd: 1000,
          periodDays: 7,
        );
        expect(apr, lessThan(0));
      },
    );
  });
}

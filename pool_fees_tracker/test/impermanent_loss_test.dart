import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/impermanent_loss.dart';

void main() {
  group('computeImpermanentLoss', () {
    test('sem variação de preço (entry == current), IL é ~0', () {
      final result = computeImpermanentLoss(
        entryTick: 100,
        currentTick: 100,
        initialLiquidityUsd: 5000,
      );
      expect(result.lossPct, closeTo(0, 1e-9));
      expect(result.lossUsd, closeTo(0, 1e-9));
    });

    test('nunca dá ganho (lossPct é sempre ≤ 0)', () {
      for (final delta in [-5000, -500, -1, 1, 500, 5000]) {
        final result = computeImpermanentLoss(
          entryTick: 0,
          currentTick: delta,
          initialLiquidityUsd: 1000,
        );
        expect(
          result.lossPct,
          lessThanOrEqualTo(0),
          reason: 'tickDelta=$delta',
        );
      }
    });

    test('é simétrico: subir ou descer o mesmo rácio dá a mesma perda', () {
      final up = computeImpermanentLoss(
        entryTick: 0,
        currentTick: 1000,
        initialLiquidityUsd: 1000,
      );
      final down = computeImpermanentLoss(
        entryTick: 0,
        currentTick: -1000,
        initialLiquidityUsd: 1000,
      );
      // 1.0001^1000 e o seu inverso 1.0001^-1000 dão quase a mesma
      // magnitude de IL (a fórmula é simétrica em log do rácio).
      expect(up.lossPct, closeTo(down.lossPct, 0.05));
    });

    test('lossUsd escala com o capital inicial', () {
      final small = computeImpermanentLoss(
        entryTick: 0,
        currentTick: 2000,
        initialLiquidityUsd: 1000,
      );
      final big = computeImpermanentLoss(
        entryTick: 0,
        currentTick: 2000,
        initialLiquidityUsd: 10000,
      );
      expect(big.lossUsd, closeTo(small.lossUsd * 10, 0.01));
    });

    test(
      'uma variação de preço grande produz uma perda maior que uma pequena',
      () {
        final small = computeImpermanentLoss(
          entryTick: 0,
          currentTick: 100,
          initialLiquidityUsd: 1000,
        );
        final big = computeImpermanentLoss(
          entryTick: 0,
          currentTick: 5000,
          initialLiquidityUsd: 1000,
        );
        expect(big.lossPct, lessThan(small.lossPct));
      },
    );
  });
}

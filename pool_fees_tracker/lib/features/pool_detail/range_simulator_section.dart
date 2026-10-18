import 'package:flutter/material.dart';

import '../../core/calc/range_simulator.dart';
import '../../core/calc/univ3_fee_math.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/price_point.dart';

/// Backtest de larguras de range alternativas contra o histórico de preço
/// já gravado desta posição — "e se tivesse escolhido um range mais
/// estreito/largo?" Aproximação explícita: o multiplicador de
/// concentração de fees é `1/largura`, ignorando a liquidez real de
/// outros LPs na pool.
class RangeSimulatorSection extends StatelessWidget {
  final List<PricePoint> pricePoints;
  final int actualTickLower;
  final int actualTickUpper;
  final int entryTick;
  final int token0Decimals;
  final int token1Decimals;
  final String token0Symbol;
  final String token1Symbol;

  const RangeSimulatorSection({
    super.key,
    required this.pricePoints,
    required this.actualTickLower,
    required this.actualTickUpper,
    required this.entryTick,
    required this.token0Decimals,
    required this.token1Decimals,
    required this.token0Symbol,
    required this.token1Symbol,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final results = simulateRangeWidths(
      pricePoints: pricePoints,
      actualTickLower: actualTickLower,
      actualTickUpper: actualTickUpper,
      entryTick: entryTick,
    );

    if (results.length < 2) {
      return Text(
        'Not enough price history yet to simulate alternate ranges',
        style: TextStyle(fontSize: 11.5, color: palette.textTertiary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What if you had chosen a different range width? Backtested '
          'against this position\'s own recorded price history — '
          'estimate, not a prediction.',
          style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
        ),
        const SizedBox(height: 10),
        for (final result in results) ...[
          _RangeSimRow(
            result: result,
            token0Decimals: token0Decimals,
            token1Decimals: token1Decimals,
            token0Symbol: token0Symbol,
            token1Symbol: token1Symbol,
          ),
          if (result != results.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RangeSimRow extends StatelessWidget {
  final RangeSimulationResult result;
  final int token0Decimals;
  final int token1Decimals;
  final String token0Symbol;
  final String token1Symbol;

  const _RangeSimRow({
    required this.result,
    required this.token0Decimals,
    required this.token1Decimals,
    required this.token0Symbol,
    required this.token1Symbol,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isActual = result.widthMultiplier == 1.0;
    final priceLower = formatTokenPrice(
      priceAtTick(
        tick: result.lowerTick,
        token0Decimals: token0Decimals,
        token1Decimals: token1Decimals,
      ),
    );
    final priceUpper = formatTokenPrice(
      priceAtTick(
        tick: result.upperTick,
        token0Decimals: token0Decimals,
        token1Decimals: token1Decimals,
      ),
    );
    final scoreColor = result.relativeFeeScore >= 1.0
        ? palette.positive
        : palette.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActual
            ? palette.accent.withValues(alpha: 0.08)
            : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: isActual
            ? Border.all(color: palette.accent.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              isActual ? 'Actual' : '${result.widthMultiplier}×',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActual ? palette.accent : palette.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$priceLower – $priceUpper',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: palette.textPrimary),
            ),
          ),
          Text(
            '${(result.fractionInRange * 100).toStringAsFixed(0)}% in range',
            style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
          ),
          const SizedBox(width: 8),
          Text(
            '${result.relativeFeeScore.toStringAsFixed(2)}×',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/univ3_fee_math.dart';
import '../../core/format/currency_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/price_alert_rule.dart';

/// Alerta de preço do utilizador para esta posição — independente do
/// range (ver `PriceAlertRule`): "avisa-me quando o preço for
/// acima/abaixo de X", ao contrário do out-of-range que é sobre o range
/// da própria posição.
class PriceAlertSection extends ConsumerWidget {
  final String positionKey;
  final int token0Decimals;
  final int token1Decimals;
  final String token0Symbol;
  final String token1Symbol;

  const PriceAlertSection({
    super.key,
    required this.positionKey,
    required this.token0Decimals,
    required this.token1Decimals,
    required this.token0Symbol,
    required this.token1Symbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final rule = ref.watch(priceAlertRuleProvider(positionKey)).value;

    if (rule == null) {
      return OutlinedButton.icon(
        onPressed: () => _openDialog(context, ref, existing: null),
        icon: const Icon(Icons.notifications_outlined, size: 16),
        label: const Text('Definir alerta de preço'),
      );
    }

    final thresholdPrice = priceAtTick(
      tick: rule.thresholdTick,
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
    );
    final directionLabel = rule.direction == PriceAlertDirection.above
        ? 'subir acima de'
        : 'cair abaixo de';

    return Row(
      children: [
        Expanded(
          child: Text(
            'Alerta quando o preço $directionLabel '
            '${formatTokenPrice(thresholdPrice)} $token1Symbol por $token0Symbol',
            style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => _openDialog(context, ref, existing: rule),
          child: const Text('Editar'),
        ),
        TextButton(
          onPressed: () async {
            await ref.read(priceAlertRuleServiceProvider).clear(positionKey);
            ref.invalidate(priceAlertRuleProvider(positionKey));
          },
          child: Text('Limpar', style: TextStyle(color: palette.negative)),
        ),
      ],
    );
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref, {
    required PriceAlertRule? existing,
  }) async {
    final initialPrice = existing == null
        ? null
        : priceAtTick(
            tick: existing.thresholdTick,
            token0Decimals: token0Decimals,
            token1Decimals: token1Decimals,
          );
    final result =
        await showDialog<({double price, PriceAlertDirection direction})>(
          context: context,
          builder: (context) => _PriceAlertDialog(
            initialPrice: initialPrice,
            initialDirection: existing?.direction ?? PriceAlertDirection.above,
            token0Symbol: token0Symbol,
            token1Symbol: token1Symbol,
          ),
        );
    if (result == null) return;

    final thresholdTick = tickAtPrice(
      price: result.price,
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
    ).round();
    await ref
        .read(priceAlertRuleServiceProvider)
        .set(
          positionKey: positionKey,
          thresholdTick: thresholdTick,
          direction: result.direction,
        );
    ref.invalidate(priceAlertRuleProvider(positionKey));
  }
}

class _PriceAlertDialog extends StatefulWidget {
  final double? initialPrice;
  final PriceAlertDirection initialDirection;
  final String token0Symbol;
  final String token1Symbol;

  const _PriceAlertDialog({
    required this.initialPrice,
    required this.initialDirection,
    required this.token0Symbol,
    required this.token1Symbol,
  });

  @override
  State<_PriceAlertDialog> createState() => _PriceAlertDialogState();
}

class _PriceAlertDialogState extends State<_PriceAlertDialog> {
  late final TextEditingController _controller;
  late PriceAlertDirection _direction;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice?.toStringAsFixed(2) ?? '',
    );
    _direction = widget.initialDirection;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alerta de preço'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avisa-me quando o preço (${widget.token1Symbol} por '
            '${widget.token0Symbol}) cruzar:',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Preço (${widget.token1Symbol})',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          SegmentedButton<PriceAlertDirection>(
            segments: const [
              ButtonSegment(
                value: PriceAlertDirection.above,
                label: Text('Acima'),
              ),
              ButtonSegment(
                value: PriceAlertDirection.below,
                label: Text('Abaixo'),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (s) => setState(() => _direction = s.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final price = double.tryParse(_controller.text.trim());
            if (price == null || price <= 0) return;
            Navigator.of(context).pop((price: price, direction: _direction));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

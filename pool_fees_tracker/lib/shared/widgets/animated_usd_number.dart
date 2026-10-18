import 'package:flutter/material.dart';

import '../../core/format/currency_formatter.dart';
import '../../core/theme/app_theme.dart';

/// Número grande que anima suavemente entre o valor antigo e o novo sempre
/// que [value] muda (contagem ao abrir, pequenos saltos quando chegam fees
/// novas), e pisca a verde por um instante quando o valor sobe.
class AnimatedUsdNumber extends StatefulWidget {
  final double value;
  final CurrencyFormatter formatter;
  final double fontSize;

  const AnimatedUsdNumber({
    super.key,
    required this.value,
    required this.formatter,
    this.fontSize = 50,
  });

  @override
  State<AnimatedUsdNumber> createState() => _AnimatedUsdNumberState();
}

class _AnimatedUsdNumberState extends State<AnimatedUsdNumber> {
  double _previousValue = 0;
  bool _flashing = false;

  @override
  void didUpdateWidget(AnimatedUsdNumber old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      _previousValue = old.value;
      if (widget.value > old.value) {
        setState(() => _flashing = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _flashing = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previousValue, end: widget.value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -1,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: _flashing ? palette.positive : palette.textPrimary,
          ),
          child: Text(widget.formatter.format(animatedValue)),
        );
      },
    );
  }
}

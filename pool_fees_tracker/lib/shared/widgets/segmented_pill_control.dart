import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Segmented control genérico (usado para o intervalo 24H/7D/30D/90D/ALL e
/// para o agrupamento Hour/Day/Week/Month do gráfico de barras).
class SegmentedPillControl<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  const SegmentedPillControl({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: option == selected
                        ? palette.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelBuilder(option),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: option == selected
                          ? palette.background
                          : palette.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

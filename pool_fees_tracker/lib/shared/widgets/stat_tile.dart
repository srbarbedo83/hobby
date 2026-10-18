import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: valueColor ?? palette.textPrimary,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

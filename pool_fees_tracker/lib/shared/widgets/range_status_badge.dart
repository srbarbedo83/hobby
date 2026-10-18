import 'package:flutter/material.dart';

import '../../core/calc/range_health.dart';
import '../../core/theme/app_theme.dart';

extension RangeStatusPresentation on RangeStatus {
  Color get color => switch (this) {
    RangeStatus.inRange => AppColors.positive,
    RangeStatus.nearEdge => AppColors.warning,
    RangeStatus.outOfRange => AppColors.negative,
  };

  String get label => switch (this) {
    RangeStatus.inRange => 'In range',
    RangeStatus.nearEdge => 'Near edge',
    RangeStatus.outOfRange => 'Out of range',
  };
}

/// Pequena pill "• In range" usada nas listas de pools.
class RangeStatusPill extends StatelessWidget {
  final RangeStatus status;

  const RangeStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(status.label, style: TextStyle(fontSize: 10, color: status.color)),
      ],
    );
  }
}

/// Barra que mostra onde o preço atual está dentro do range da posição,
/// usada no ecrã de detalhe (Krystal/Revert-style "range health").
class RangeHealthBar extends StatelessWidget {
  final RangeHealth health;

  const RangeHealthBar({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    final clamped = health.positionFraction.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price range',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            RangeStatusPill(status: health.status),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final dotX = (constraints.maxWidth - 10) * clamped;
                return Padding(
                  padding: EdgeInsets.only(
                    left: dotX.clamp(0, constraints.maxWidth - 10),
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: -1),
                    decoration: BoxDecoration(
                      color: health.status.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min',
              style: TextStyle(fontSize: 9.5, color: AppColors.textTertiary),
            ),
            Text(
              'Max',
              style: TextStyle(fontSize: 9.5, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

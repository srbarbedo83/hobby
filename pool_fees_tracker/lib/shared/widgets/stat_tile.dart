import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;

  /// Quando definido, mostra um ícone (i) pequeno junto ao rótulo — ao
  /// tocar, abre a explicação (ver `showInfoSheet`). Pedido do utilizador
  /// para números cujo significado não é óbvio (Net vs. HODL, IL, ...).
  final VoidCallback? onInfoTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.caption,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    // `height: double.infinity` + o `IntrinsicHeight` dos Rows que usam
    // este tile (dashboard/detalhe) — sem isto, duas caixas lado a lado
    // só ficam da mesma altura por acaso, quando nenhuma tem `caption`
    // (pedido do utilizador: ficavam visivelmente assimétricas).
    return Container(
      height: double.infinity,
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
          Row(
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
              if (onInfoTap != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Icon(
                    Icons.info_outline,
                    size: 11,
                    color: palette.textTertiary,
                  ),
                ),
              ],
            ],
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

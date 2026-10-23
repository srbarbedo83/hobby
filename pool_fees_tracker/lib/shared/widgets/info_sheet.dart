import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Bottom sheet genérico para explicar um número/conceito ao tocar num
/// ícone (i) — mesmo padrão já usado no health score, agora reutilizável
/// em qualquer StatTile ou cabeçalho de secção, para não copiar a mesma
/// estrutura de `showModalBottomSheet` em cada sítio.
void showInfoSheet(
  BuildContext context, {
  required String title,
  required Widget body,
}) {
  final palette = AppPalette.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: palette.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: palette.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          body,
        ],
      ),
    ),
  );
}

/// Texto simples dentro do sheet — a maioria dos casos não precisa de
/// nada mais elaborado do que isto.
class InfoSheetText extends StatelessWidget {
  final String text;

  const InfoSheetText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: palette.textSecondary, height: 1.5),
    );
  }
}

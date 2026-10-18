import 'package:flutter/material.dart';

/// Pede ao utilizador para colar o texto do backup (gerado por
/// `encodeSettingsBackup` e partilhado anteriormente) — devolve o texto
/// tal como colado, sem validar; a validação acontece em
/// `decodeSettingsBackup`, chamado por quem usa este diálogo.
Future<String?> showRestoreBackupDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Restaurar backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cola aqui o conteúdo do ficheiro de backup exportado anteriormente.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '{"version": 1, "settings": {...}, ...}',
                border: OutlineInputBorder(),
              ),
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
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(context).pop(text);
            },
            child: const Text('Restaurar'),
          ),
        ],
      );
    },
  );
}

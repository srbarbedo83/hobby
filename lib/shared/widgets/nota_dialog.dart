import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Diálogo curto para anexar uma nota a uma sessão já gravada — usado
/// quando o utilizador só decide adicionar a nota depois de parar o
/// cronómetro, a partir da ação no snackbar de confirmação.
Future<void> mostrarDialogoNota(BuildContext context, WidgetRef ref, int sessaoId) async {
  final controller = TextEditingController();
  final nota = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nota da sessão'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 140,
        decoration: const InputDecoration(hintText: 'Ex.: praticei escalas hoje'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (nota != null && nota.isNotEmpty) {
    await ref.read(sessaoRepositoryProvider).atualizarNota(sessaoId, nota);
  }
}

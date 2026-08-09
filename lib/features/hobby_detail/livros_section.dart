import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/livro.dart';

final livrosPorHobbyProvider = StreamProvider.family<List<Livro>, int>((ref, hobbyId) {
  return ref.watch(livroRepositoryProvider).watchPorHobby(hobbyId);
});

/// Só para livros — não é um sistema genérico de "itens" por tipo de
/// hobby, é uma secção específica para quem usa a app para leitura.
class LivrosSection extends ConsumerWidget {
  const LivrosSection({super.key, required this.hobbyId, required this.cor});

  final int hobbyId;
  final Color cor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livrosAsync = ref.watch(livrosPorHobbyProvider(hobbyId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        livrosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Erro a carregar livros: $err'),
          data: (livros) {
            if (livros.isEmpty) {
              return Text(
                'Ainda não adicionaste nenhum livro.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              );
            }
            return Column(
              children: [for (final livro in livros) _LinhaLivro(livro: livro, cor: cor)],
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _mostrarFormularioLivro(context, ref, hobbyId: hobbyId),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar livro'),
        ),
      ],
    );
  }
}

class _LinhaLivro extends ConsumerWidget {
  const _LinhaLivro({required this.livro, required this.cor});

  final Livro livro;
  final Color cor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concluido = livro.dataConclusao != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          concluido ? Icons.check_circle : Icons.radio_button_unchecked,
          color: cor,
        ),
        tooltip: concluido ? 'Marcar como a ler' : 'Marcar como lido',
        onPressed: () {
          livro.dataConclusao = concluido ? null : DateTime.now();
          ref.read(livroRepositoryProvider).guardar(livro);
        },
      ),
      title: Text(
        livro.titulo,
        style: TextStyle(decoration: concluido ? TextDecoration.lineThrough : null),
      ),
      subtitle: livro.autor != null && livro.autor!.isNotEmpty ? Text(livro.autor!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        tooltip: 'Apagar livro',
        onPressed: () => ref.read(livroRepositoryProvider).apagar(livro.id),
      ),
      onTap: () => _mostrarFormularioLivro(context, ref, hobbyId: livro.hobbyId, inicial: livro),
    );
  }
}

Future<void> _mostrarFormularioLivro(
  BuildContext context,
  WidgetRef ref, {
  required int hobbyId,
  Livro? inicial,
}) async {
  final tituloController = TextEditingController(text: inicial?.titulo ?? '');
  final autorController = TextEditingController(text: inicial?.autor ?? '');

  final guardar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(inicial == null ? 'Novo livro' : 'Editar livro'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: tituloController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: autorController,
            decoration: const InputDecoration(labelText: 'Autor (opcional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (guardar != true) return;
  final titulo = tituloController.text.trim();
  if (titulo.isEmpty) return;

  final livro = inicial ?? Livro();
  livro
    ..hobbyId = hobbyId
    ..titulo = titulo
    ..autor = autorController.text.trim().isEmpty ? null : autorController.text.trim()
    ..criadoEm = inicial?.criadoEm ?? DateTime.now();

  await ref.read(livroRepositoryProvider).guardar(livro);
}

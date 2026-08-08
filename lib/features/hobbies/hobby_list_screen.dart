import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/meta_formatter.dart';
import 'hobby_form_screen.dart';
import 'hobby_providers.dart';

class HobbyListScreen extends ConsumerWidget {
  const HobbyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hobbiesAsync = ref.watch(hobbiesAtivosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Os teus hobbies')),
      body: hobbiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro a carregar hobbies: $err')),
        data: (hobbies) {
          if (hobbies.isEmpty) {
            return const _EstadoVazio();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: hobbies.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final hobby = hobbies[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(hobby.cor),
                  foregroundColor: Colors.white,
                  // ignore: non_const_argument_for_const_parameter
                  child: Icon(IconData(hobby.icone, fontFamily: 'MaterialIcons')),
                ),
                title: Text(hobby.nome),
                subtitle: Text(formatarMeta(hobby.meta)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HobbyFormScreen(hobbyId: hobby.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HobbyFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text(
              'Ainda não tens hobbies.\nToca em + para criar o primeiro.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

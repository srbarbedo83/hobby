import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/sessao_registada.dart';

/// Edita a duração e a nota de uma sessão já gravada — não importa se
/// veio do cronómetro ou de registo manual, o tempo é sempre corrigível.
class EditarSessaoSheet extends ConsumerStatefulWidget {
  const EditarSessaoSheet({super.key, required this.sessao, required this.cor});

  final SessaoRegistada sessao;
  final Color cor;

  static Future<void> mostrar(
    BuildContext context, {
    required SessaoRegistada sessao,
    required Color cor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditarSessaoSheet(sessao: sessao, cor: cor),
    );
  }

  @override
  ConsumerState<EditarSessaoSheet> createState() => _EditarSessaoSheetState();
}

class _EditarSessaoSheetState extends ConsumerState<EditarSessaoSheet> {
  late final TextEditingController _horasController;
  late final TextEditingController _minutosController;
  late final TextEditingController _notaController;
  bool _aProcessar = false;

  @override
  void initState() {
    super.initState();
    final duracao = Duration(seconds: widget.sessao.duracaoSegundos);
    _horasController = TextEditingController(text: '${duracao.inHours}');
    _minutosController = TextEditingController(text: '${duracao.inMinutes.remainder(60)}');
    _notaController = TextEditingController(text: widget.sessao.nota ?? '');
  }

  @override
  void dispose() {
    _horasController.dispose();
    _minutosController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final horas = int.tryParse(_horasController.text) ?? 0;
    final minutos = int.tryParse(_minutosController.text) ?? 0;
    final segundos = horas * 3600 + minutos * 60;
    if (segundos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica uma duração maior que zero')),
      );
      return;
    }

    setState(() => _aProcessar = true);
    final nota = _notaController.text.trim();
    widget.sessao
      ..duracaoSegundos = segundos
      ..nota = nota.isEmpty ? null : nota;
    await ref.read(sessaoRepositoryProvider).guardar(widget.sessao);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _apagar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar sessão?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _aProcessar = true);
    await ref.read(sessaoRepositoryProvider).apagar(widget.sessao.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Editar sessão', style: Theme.of(context).textTheme.titleMedium),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Apagar sessão',
                onPressed: _aProcessar ? null : _apagar,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _horasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Horas'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _minutosController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notaController,
            maxLength: 140,
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _aProcessar ? null : _guardar,
            child: Text(_aProcessar ? 'A guardar…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

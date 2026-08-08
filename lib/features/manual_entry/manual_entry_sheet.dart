import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/duration_formatter.dart';
import '../../core/providers.dart';
import '../../data/local/sessao_registada.dart';

/// Alternativa ao cronómetro para quando o utilizador já terminou o hobby
/// e só quer registar a duração: atalhos rápidos ou uma duração exata.
class ManualEntrySheet extends ConsumerStatefulWidget {
  const ManualEntrySheet({
    super.key,
    required this.hobbyId,
    required this.hobbyNome,
    required this.cor,
  });

  final int hobbyId;
  final String hobbyNome;
  final Color cor;

  static Future<void> mostrar(
    BuildContext context, {
    required int hobbyId,
    required String hobbyNome,
    required Color cor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ManualEntrySheet(hobbyId: hobbyId, hobbyNome: hobbyNome, cor: cor),
    );
  }

  @override
  ConsumerState<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends ConsumerState<ManualEntrySheet> {
  final _horasController = TextEditingController();
  final _minutosController = TextEditingController();
  bool _aGuardar = false;

  @override
  void dispose() {
    _horasController.dispose();
    _minutosController.dispose();
    super.dispose();
  }

  Future<void> _guardarExata() async {
    final horas = int.tryParse(_horasController.text) ?? 0;
    final minutos = int.tryParse(_minutosController.text) ?? 0;
    final segundos = horas * 3600 + minutos * 60;
    if (segundos <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica uma duração maior que zero')),
      );
      return;
    }
    await _guardar(segundos);
  }

  Future<void> _guardar(int segundos) async {
    setState(() => _aGuardar = true);
    await ref.read(sessaoRepositoryProvider).guardar(
          SessaoRegistada()
            ..hobbyId = widget.hobbyId
            ..inicio = DateTime.now()
            ..duracaoSegundos = segundos
            ..origem = OrigemSessao.manual,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sessão de ${formatarDuracao(segundos)} guardada')),
    );
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
          Text('Registar tempo — ${widget.hobbyNome}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AtalhoChip(
                rotulo: '+15 min',
                cor: widget.cor,
                onTap: _aGuardar ? null : () => _guardar(const Duration(minutes: 15).inSeconds),
              ),
              _AtalhoChip(
                rotulo: '+30 min',
                cor: widget.cor,
                onTap: _aGuardar ? null : () => _guardar(const Duration(minutes: 30).inSeconds),
              ),
              _AtalhoChip(
                rotulo: '+1 h',
                cor: widget.cor,
                onTap: _aGuardar ? null : () => _guardar(const Duration(hours: 1).inSeconds),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Ou introduz uma duração exata', style: Theme.of(context).textTheme.labelLarge),
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _aGuardar ? null : _guardarExata,
            child: Text(_aGuardar ? 'A guardar…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}

class _AtalhoChip extends StatelessWidget {
  const _AtalhoChip({required this.rotulo, required this.cor, required this.onTap});

  final String rotulo;
  final Color cor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(rotulo),
      onPressed: onTap,
      side: BorderSide(color: cor),
      backgroundColor: cor.withValues(alpha: 0.08),
    );
  }
}

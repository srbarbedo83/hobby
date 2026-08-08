import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/hobby.dart';
import 'hobby_providers.dart';

/// Ecrã de criar/editar hobby. Passa `hobbyId` para editar um existente;
/// omite para criar um novo.
class HobbyFormScreen extends ConsumerWidget {
  const HobbyFormScreen({super.key, this.hobbyId});

  final int? hobbyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = hobbyId;
    if (id == null) {
      return const _HobbyFormBody(hobbyId: null, inicial: null);
    }

    final hobbyAsync = ref.watch(hobbyByIdProvider(id));
    return hobbyAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Erro a carregar hobby: $err'))),
      data: (hobby) => _HobbyFormBody(hobbyId: id, inicial: hobby),
    );
  }
}

class _HobbyFormBody extends ConsumerStatefulWidget {
  const _HobbyFormBody({required this.hobbyId, required this.inicial});

  final int? hobbyId;
  final Hobby? inicial;

  @override
  ConsumerState<_HobbyFormBody> createState() => _HobbyFormBodyState();
}

class _HobbyFormBodyState extends ConsumerState<_HobbyFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _valorMinutosController;
  late final TextEditingController _numeroSessoesController;

  late int _icone;
  late Color _cor;
  late bool _temMeta;
  late TipoMeta _tipoMeta;
  late Periodicidade _periodicidade;
  bool _aGuardar = false;

  bool get _editando => widget.inicial != null;

  @override
  void initState() {
    super.initState();
    final inicial = widget.inicial;
    final meta = inicial?.meta;

    _nomeController = TextEditingController(text: inicial?.nome ?? '');
    _icone = inicial?.icone ?? hobbyIconChoices.first.codePoint;
    _cor = inicial != null ? Color(inicial.cor) : hobbyColorPalette.first;
    _temMeta = meta != null;
    _tipoMeta = meta?.tipo ?? TipoMeta.semanal;
    _periodicidade = meta?.periodicidade ?? Periodicidade.semanal;
    _valorMinutosController = TextEditingController(
      text: meta?.valorMinutos?.toString() ?? '',
    );
    _numeroSessoesController = TextEditingController(
      text: meta?.numeroSessoes?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorMinutosController.dispose();
    _numeroSessoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar hobby' : 'Novo hobby')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Dá um nome ao hobby' : null,
            ),
            const SizedBox(height: 24),
            Text('Ícone', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _IconePicker(
              selecionado: _icone,
              cor: _cor,
              onSelecionado: (icone) => setState(() => _icone = icone),
            ),
            const SizedBox(height: 24),
            Text('Cor', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _CorPicker(
              selecionada: _cor,
              onSelecionada: (cor) => setState(() => _cor = cor),
            ),
            const SizedBox(height: 24),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Definir meta de assiduidade'),
              subtitle: const Text('Opcional — compara tempo real investido com um alvo'),
              value: _temMeta,
              onChanged: (v) => setState(() => _temMeta = v),
            ),
            if (_temMeta) _MetaFields(
              tipoMeta: _tipoMeta,
              periodicidade: _periodicidade,
              valorMinutosController: _valorMinutosController,
              numeroSessoesController: _numeroSessoesController,
              onTipoMetaChanged: (t) => setState(() => _tipoMeta = t),
              onPeriodicidadeChanged: (p) => setState(() => _periodicidade = p),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _aGuardar ? null : _guardar,
              child: Text(_aGuardar ? 'A guardar…' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    Meta? meta;
    if (_temMeta) {
      meta = Meta()
        ..tipo = _tipoMeta
        ..periodicidade = _periodicidade
        ..valorMinutos = _tipoMeta == TipoMeta.porNumeroSessoes
            ? null
            : int.tryParse(_valorMinutosController.text)
        ..numeroSessoes = _tipoMeta == TipoMeta.porNumeroSessoes
            ? int.tryParse(_numeroSessoesController.text)
            : null;
    }

    final hobby = Hobby()
      ..id = widget.inicial?.id ?? 0
      ..nome = _nomeController.text.trim()
      ..icone = _icone
      ..cor = _cor.toARGB32()
      ..ativo = true
      ..criadoEm = widget.inicial?.criadoEm ?? DateTime.now()
      ..meta = meta;

    setState(() => _aGuardar = true);
    await ref.read(hobbyRepositoryProvider).guardar(hobby);
    if (mounted) Navigator.of(context).pop();
  }
}

class _IconePicker extends StatelessWidget {
  const _IconePicker({required this.selecionado, required this.cor, required this.onSelecionado});

  final int selecionado;
  final Color cor;
  final ValueChanged<int> onSelecionado;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hobbyIconChoices.map((icon) {
        final ativo = icon.codePoint == selecionado;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onSelecionado(icon.codePoint),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: ativo ? cor : Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: ativo ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            child: Icon(icon),
          ),
        );
      }).toList(),
    );
  }
}

class _CorPicker extends StatelessWidget {
  const _CorPicker({required this.selecionada, required this.onSelecionada});

  final Color selecionada;
  final ValueChanged<Color> onSelecionada;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hobbyColorPalette.map((cor) {
        final ativa = cor.toARGB32() == selecionada.toARGB32();
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelecionada(cor),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cor,
              shape: BoxShape.circle,
              border: ativa ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2) : null,
            ),
            child: ativa ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        );
      }).toList(),
    );
  }
}

class _MetaFields extends StatelessWidget {
  const _MetaFields({
    required this.tipoMeta,
    required this.periodicidade,
    required this.valorMinutosController,
    required this.numeroSessoesController,
    required this.onTipoMetaChanged,
    required this.onPeriodicidadeChanged,
  });

  final TipoMeta tipoMeta;
  final Periodicidade periodicidade;
  final TextEditingController valorMinutosController;
  final TextEditingController numeroSessoesController;
  final ValueChanged<TipoMeta> onTipoMetaChanged;
  final ValueChanged<Periodicidade> onPeriodicidadeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<TipoMeta>(
          initialValue: tipoMeta,
          decoration: const InputDecoration(labelText: 'Tipo de meta'),
          items: const [
            DropdownMenuItem(value: TipoMeta.diaria, child: Text('Minutos por dia')),
            DropdownMenuItem(value: TipoMeta.semanal, child: Text('Minutos por semana')),
            DropdownMenuItem(value: TipoMeta.porNumeroSessoes, child: Text('Número de sessões')),
          ],
          onChanged: (v) {
            if (v != null) onTipoMetaChanged(v);
          },
        ),
        const SizedBox(height: 16),
        if (tipoMeta == TipoMeta.porNumeroSessoes) ...[
          TextFormField(
            controller: numeroSessoesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nº de sessões'),
            validator: (v) => _validarInteiroPositivo(v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Periodicidade>(
            initialValue: periodicidade,
            decoration: const InputDecoration(labelText: 'Por'),
            items: const [
              DropdownMenuItem(value: Periodicidade.diario, child: Text('Dia')),
              DropdownMenuItem(value: Periodicidade.semanal, child: Text('Semana')),
            ],
            onChanged: (v) {
              if (v != null) onPeriodicidadeChanged(v);
            },
          ),
        ] else
          TextFormField(
            controller: valorMinutosController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: tipoMeta == TipoMeta.diaria ? 'Minutos por dia' : 'Minutos por semana',
            ),
            validator: (v) => _validarInteiroPositivo(v),
          ),
      ],
    );
  }

  String? _validarInteiroPositivo(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Indica um valor válido';
    return null;
  }
}

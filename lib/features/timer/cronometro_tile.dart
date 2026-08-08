import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/duration_formatter.dart';
import '../../data/local/estado_cronometro.dart';
import '../../shared/widgets/nota_dialog.dart';
import '../manual_entry/manual_entry_sheet.dart';
import 'timer_providers.dart';

/// Controlos de cronómetro de um hobby: iniciar quando parado, pausar/parar
/// quando ativo. Cada instância só depende do seu próprio [hobbyId], por
/// isso vários hobbies podem ter o cronómetro a correr ao mesmo tempo.
///
/// Enquanto parado, mostra também o atalho de registo manual — deixa de
/// aparecer assim que há um cronómetro ativo, para não sobrecarregar a fila
/// de ícones precisamente quando ela já tem mais controlos.
class CronometroTile extends ConsumerWidget {
  const CronometroTile({
    super.key,
    required this.hobbyId,
    required this.hobbyNome,
    required this.cor,
  });

  final int hobbyId;
  final String hobbyNome;
  final Color cor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAsync = ref.watch(cronometroPorHobbyProvider(hobbyId));
    final controller = ref.read(timerControllerProvider);

    return estadoAsync.when(
      loading: () => const SizedBox(width: 40, height: 40),
      error: (_, _) => const Icon(Icons.error_outline),
      data: (estado) {
        if (estado == null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.more_time, color: cor),
                tooltip: 'Registar tempo manualmente',
                onPressed: () => ManualEntrySheet.mostrar(
                  context,
                  hobbyId: hobbyId,
                  hobbyNome: hobbyNome,
                  cor: cor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.play_arrow, color: cor),
                tooltip: 'Iniciar cronómetro',
                onPressed: () => controller.iniciar(hobbyId),
              ),
            ],
          );
        }

        final aCorrer = estado.estado == EstadoExecucao.emExecucao;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ElapsedText(estado: estado, cor: cor),
            IconButton(
              icon: Icon(aCorrer ? Icons.pause : Icons.play_arrow, color: cor),
              tooltip: aCorrer ? 'Pausar' : 'Retomar',
              onPressed: () =>
                  aCorrer ? controller.pausar(hobbyId) : controller.retomar(hobbyId),
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              tooltip: 'Terminar e guardar sessão',
              onPressed: () async {
                final resultado = await controller.parar(hobbyId);
                if (context.mounted && resultado != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sessão guardada: ${formatarDuracao(resultado.duracaoSegundos)}'),
                      action: SnackBarAction(
                        label: 'Adicionar nota',
                        onPressed: () => mostrarDialogoNota(context, ref, resultado.sessaoId),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _ElapsedText extends StatefulWidget {
  const _ElapsedText({required this.estado, required this.cor});

  final EstadoCronometro estado;
  final Color cor;

  @override
  State<_ElapsedText> createState() => _ElapsedTextState();
}

class _ElapsedTextState extends State<_ElapsedText> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _sincronizarTicker();
  }

  @override
  void didUpdateWidget(covariant _ElapsedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sincronizarTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// O timer local só serve para redesenhar o número a cada segundo — a
  /// duração em si é sempre recalculada a partir do timestamp persistido.
  void _sincronizarTicker() {
    final aCorrer = widget.estado.estado == EstadoExecucao.emExecucao;
    if (aCorrer && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    } else if (!aCorrer && _ticker != null) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatarDuracao(widget.estado.elapsedSegundos()),
      style: TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
        color: widget.cor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

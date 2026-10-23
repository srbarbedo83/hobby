import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'info_sheet.dart';

/// Pequeno indicador "● LIVE" com o ponto a pulsar, para sinalizar que um
/// número está a atualizar-se em tempo real (não é um screenshot estático).
///
/// Quando [isStale] é `true` (ver `isDataStale`), troca para um aviso
/// "SEM ATUALIZAR" em cor de aviso, com o ponto parado em vez de a pulsar
/// — o refresh automático parece ter parado (sem rede, RPC em baixo).
class LiveBadge extends StatefulWidget {
  final bool isStale;

  const LiveBadge({super.key, this.isStale = false});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = widget.isStale ? palette.warning : palette.accent;
    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    return GestureDetector(
      onTap: () => showInfoSheet(
        context,
        title: widget.isStale ? 'Sem atualizar' : 'Live',
        body: InfoSheetText(
          widget.isStale
              ? 'O último refresh automático foi há demasiado tempo '
                    '(mais do que 3× o intervalo configurado nas '
                    'Definições) — normalmente sinal de sem rede, RPC em '
                    'baixo, ou a app ter estado em background há muito '
                    'tempo. Os números na página podem estar desatualizados. '
                    'Puxa para atualizar ou tenta de novo mais tarde.'
              : 'Os números nesta página atualizam-se automaticamente, ao '
                    'ritmo definido em Definições → Intervalo de refresh. O '
                    'ponto a pulsar confirma que o último refresh correu '
                    'sem erros.',
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isStale
                ? dot
                : FadeTransition(
                    opacity: _controller.drive(Tween(begin: 0.35, end: 1.0)),
                    child: dot,
                  ),
            const SizedBox(width: 5),
            Text(
              widget.isStale ? 'SEM ATUALIZAR' : 'LIVE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

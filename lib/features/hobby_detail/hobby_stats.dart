import 'dart:math' as math;

import '../../data/local/sessao_registada.dart';

class HobbyStats {
  const HobbyStats({
    required this.totalSegundos,
    required this.mediaSemanalSegundos,
    required this.sessaoMaisLongaSegundos,
    required this.numeroSessoes,
  });

  final int totalSegundos;
  final int mediaSemanalSegundos;
  final int sessaoMaisLongaSegundos;
  final int numeroSessoes;

  static const vazio = HobbyStats(
    totalSegundos: 0,
    mediaSemanalSegundos: 0,
    sessaoMaisLongaSegundos: 0,
    numeroSessoes: 0,
  );

  /// Média semanal = total ÷ nº de semanas desde a primeira sessão — não
  /// desde a criação do hobby, para não diluir a média com semanas em que
  /// o hobby ainda nem existia.
  factory HobbyStats.calcular(List<SessaoRegistada> sessoes) {
    if (sessoes.isEmpty) return vazio;

    var total = 0;
    var maisLonga = 0;
    var primeira = sessoes.first.inicio;
    for (final sessao in sessoes) {
      total += sessao.duracaoSegundos;
      if (sessao.duracaoSegundos > maisLonga) maisLonga = sessao.duracaoSegundos;
      if (sessao.inicio.isBefore(primeira)) primeira = sessao.inicio;
    }

    final dias = DateTime.now().difference(primeira).inDays + 1;
    final semanas = math.max(1, (dias / 7).ceil());

    return HobbyStats(
      totalSegundos: total,
      mediaSemanalSegundos: total ~/ semanas,
      sessaoMaisLongaSegundos: maisLonga,
      numeroSessoes: sessoes.length,
    );
  }
}

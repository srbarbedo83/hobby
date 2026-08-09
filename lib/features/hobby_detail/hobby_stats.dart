import 'dart:math' as math;

import '../../data/local/sessao_registada.dart';

class HobbyStats {
  const HobbyStats({
    required this.totalSegundos,
    required this.estaSemanaSegundos,
    required this.esteMesSegundos,
    required this.mediaSemanalSegundos,
    required this.mediaPorSessaoSegundos,
    required this.sessaoMaisLongaSegundos,
    required this.sessaoMaisCurtaSegundos,
    required this.numeroSessoes,
    required this.numeroSessoesCronometro,
    required this.numeroSessoesManual,
    required this.diasComSessoes,
    required this.ultimaSessao,
  });

  final int totalSegundos;
  final int estaSemanaSegundos;
  final int esteMesSegundos;
  final int mediaSemanalSegundos;
  final int mediaPorSessaoSegundos;
  final int sessaoMaisLongaSegundos;
  final int sessaoMaisCurtaSegundos;
  final int numeroSessoes;
  final int numeroSessoesCronometro;
  final int numeroSessoesManual;
  final int diasComSessoes;
  final DateTime? ultimaSessao;

  static const vazio = HobbyStats(
    totalSegundos: 0,
    estaSemanaSegundos: 0,
    esteMesSegundos: 0,
    mediaSemanalSegundos: 0,
    mediaPorSessaoSegundos: 0,
    sessaoMaisLongaSegundos: 0,
    sessaoMaisCurtaSegundos: 0,
    numeroSessoes: 0,
    numeroSessoesCronometro: 0,
    numeroSessoesManual: 0,
    diasComSessoes: 0,
    ultimaSessao: null,
  );

  /// Média semanal = total ÷ nº de semanas desde a primeira sessão — não
  /// desde a criação do hobby, para não diluir a média com semanas em que
  /// o hobby ainda nem existia.
  factory HobbyStats.calcular(List<SessaoRegistada> sessoes, {DateTime? agora}) {
    if (sessoes.isEmpty) return vazio;

    final hoje = _apenasData(agora ?? DateTime.now());
    final segundaFeira = hoje.subtract(Duration(days: hoje.weekday - 1));
    final inicioDoMes = DateTime(hoje.year, hoje.month);

    var total = 0;
    var estaSemana = 0;
    var esteMes = 0;
    var maisLonga = 0;
    var maisCurta = sessoes.first.duracaoSegundos;
    var cronometro = 0;
    var manual = 0;
    var primeira = sessoes.first.inicio;
    var ultima = sessoes.first.inicio;
    final diasDistintos = <DateTime>{};

    for (final sessao in sessoes) {
      total += sessao.duracaoSegundos;
      if (sessao.duracaoSegundos > maisLonga) maisLonga = sessao.duracaoSegundos;
      if (sessao.duracaoSegundos < maisCurta) maisCurta = sessao.duracaoSegundos;
      if (sessao.inicio.isBefore(primeira)) primeira = sessao.inicio;
      if (sessao.inicio.isAfter(ultima)) ultima = sessao.inicio;

      final dia = _apenasData(sessao.inicio);
      diasDistintos.add(dia);
      if (!dia.isBefore(segundaFeira)) estaSemana += sessao.duracaoSegundos;
      if (!dia.isBefore(inicioDoMes)) esteMes += sessao.duracaoSegundos;

      if (sessao.origem == OrigemSessao.cronometro) {
        cronometro++;
      } else {
        manual++;
      }
    }

    final dias = hoje.difference(_apenasData(primeira)).inDays + 1;
    final semanas = math.max(1, (dias / 7).ceil());

    return HobbyStats(
      totalSegundos: total,
      estaSemanaSegundos: estaSemana,
      esteMesSegundos: esteMes,
      mediaSemanalSegundos: total ~/ semanas,
      mediaPorSessaoSegundos: total ~/ sessoes.length,
      sessaoMaisLongaSegundos: maisLonga,
      sessaoMaisCurtaSegundos: maisCurta,
      numeroSessoes: sessoes.length,
      numeroSessoesCronometro: cronometro,
      numeroSessoesManual: manual,
      diasComSessoes: diasDistintos.length,
      ultimaSessao: ultima,
    );
  }
}

DateTime _apenasData(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

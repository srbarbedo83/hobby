import '../../data/local/sessao_registada.dart';

class PontoSemanal {
  const PontoSemanal({
    required this.inicioSemana,
    required this.minutos,
    required this.projetado,
  });

  final DateTime inicioSemana;
  final double minutos;

  /// `true` para os pontos estimados a partir do ritmo recente, não dados reais.
  final bool projetado;
}

/// Totais semanais das últimas [semanasHistorico] semanas (a atual
/// incluída, mesmo que ainda incompleta), seguidos de [semanasProjecao]
/// pontos estimados a partir da média das últimas [janelaMomentum] semanas
/// já fechadas — uma extrapolação simples do ritmo recente, não uma
/// previsão a sério.
List<PontoSemanal> calcularTendenciaSemanal(
  List<SessaoRegistada> sessoes, {
  int semanasHistorico = 8,
  int semanasProjecao = 2,
  int janelaMomentum = 4,
  DateTime? agora,
}) {
  final hoje = _apenasData(agora ?? DateTime.now());
  final segundaAtual = hoje.subtract(Duration(days: hoje.weekday - 1));
  final primeiraSemana = segundaAtual.subtract(Duration(days: 7 * (semanasHistorico - 1)));

  final porSemana = <DateTime, int>{};
  for (final sessao in sessoes) {
    final dia = _apenasData(sessao.inicio);
    final segunda = dia.subtract(Duration(days: dia.weekday - 1));
    porSemana[segunda] = (porSemana[segunda] ?? 0) + sessao.duracaoSegundos;
  }

  final historico = List.generate(semanasHistorico, (i) {
    final inicioSemana = primeiraSemana.add(Duration(days: 7 * i));
    final segundos = porSemana[inicioSemana] ?? 0;
    return PontoSemanal(inicioSemana: inicioSemana, minutos: segundos / 60, projetado: false);
  });

  // Só semanas já fechadas (não a atual, ainda a meio) entram no ritmo.
  final semanasFechadas = historico.where((p) => p.inicioSemana.isBefore(segundaAtual)).toList();
  final janela = semanasFechadas.length > janelaMomentum
      ? semanasFechadas.sublist(semanasFechadas.length - janelaMomentum)
      : semanasFechadas;
  final momentum = janela.isEmpty
      ? 0.0
      : janela.map((p) => p.minutos).reduce((a, b) => a + b) / janela.length;

  final projecao = List.generate(semanasProjecao, (i) {
    final inicioSemana = segundaAtual.add(Duration(days: 7 * (i + 1)));
    return PontoSemanal(inicioSemana: inicioSemana, minutos: momentum, projetado: true);
  });

  return [...historico, ...projecao];
}

DateTime _apenasData(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

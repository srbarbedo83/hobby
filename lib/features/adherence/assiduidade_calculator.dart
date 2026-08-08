import '../../data/local/hobby.dart';
import '../../data/local/sessao_registada.dart';

enum UnidadeMeta { tempo, sessoes }

enum PeriodoAssiduidade { semana, dia }

class Assiduidade {
  const Assiduidade({
    required this.percentagem,
    required this.unidade,
    required this.realizado,
    required this.alvo,
    required this.periodo,
  });

  /// Pode ultrapassar 100 — o excedente é informação útil, não é limitado
  /// aqui; quem desenha a barra é que decide saturar visualmente a 100%.
  final double percentagem;
  final UnidadeMeta unidade;
  final int realizado;
  final int alvo;
  final PeriodoAssiduidade periodo;
}

/// `null` se o hobby não tiver meta definida.
///
/// Tanto `diaria` como `semanal` comparam o acumulado desde segunda-feira
/// contra o alvo da semana inteira (não proporcional aos dias já
/// decorridos) — é a mesma lógica do exemplo do plano: "queria 3h de piano
/// por semana, fiz 1h50 = 62%", que não se ajusta consoante o dia da semana.
Assiduidade? calcularAssiduidade(Hobby hobby, List<SessaoRegistada> sessoes, {DateTime? agora}) {
  final meta = hobby.meta;
  if (meta == null) return null;

  final hoje = _apenasData(agora ?? DateTime.now());
  final segundaFeira = hoje.subtract(Duration(days: hoje.weekday - 1));
  final domingo = segundaFeira.add(const Duration(days: 6));

  switch (meta.tipo) {
    case TipoMeta.semanal:
    case TipoMeta.diaria:
      final multiplicador = meta.tipo == TipoMeta.diaria ? 7 : 1;
      final alvoSegundos = (meta.valorMinutos ?? 0) * 60 * multiplicador;
      final realizado = _somaNoPeriodo(sessoes, desde: segundaFeira, ate: domingo);
      return Assiduidade(
        percentagem: alvoSegundos <= 0 ? 0 : realizado / alvoSegundos * 100,
        unidade: UnidadeMeta.tempo,
        realizado: realizado,
        alvo: alvoSegundos,
        periodo: PeriodoAssiduidade.semana,
      );

    case TipoMeta.porNumeroSessoes:
      final diario = meta.periodicidade == Periodicidade.diario;
      final inicioPeriodo = diario ? hoje : segundaFeira;
      final fimPeriodo = diario ? hoje : domingo;
      final alvo = meta.numeroSessoes ?? 0;
      final realizado = sessoes.where((s) {
        final dia = _apenasData(s.inicio);
        return s.duracaoSegundos > 0 && !dia.isBefore(inicioPeriodo) && !dia.isAfter(fimPeriodo);
      }).length;
      return Assiduidade(
        percentagem: alvo <= 0 ? 0 : realizado / alvo * 100,
        unidade: UnidadeMeta.sessoes,
        realizado: realizado,
        alvo: alvo,
        periodo: diario ? PeriodoAssiduidade.dia : PeriodoAssiduidade.semana,
      );
  }
}

int _somaNoPeriodo(List<SessaoRegistada> sessoes, {required DateTime desde, required DateTime ate}) {
  var soma = 0;
  for (final sessao in sessoes) {
    final dia = _apenasData(sessao.inicio);
    if (!dia.isBefore(desde) && !dia.isAfter(ate)) soma += sessao.duracaoSegundos;
  }
  return soma;
}

DateTime _apenasData(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

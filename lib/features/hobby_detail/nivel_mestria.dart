/// Escala fixa e aproximada, só para motivar — não é uma métrica
/// científica, é a mesma ideia popular das "10.000 horas para ficar
/// especialista", partida em patamares intermédios mais próximos.
class Patamar {
  const Patamar(this.horas, this.nome);

  final int horas;
  final String nome;
}

const escalaMestria = [
  Patamar(0, 'Iniciante'),
  Patamar(300, 'Iniciante-intermédio'),
  Patamar(400, 'Autónomo'),
  Patamar(900, 'Bom'),
  Patamar(2000, 'Muito bom'),
  Patamar(5000, 'Avançado'),
  Patamar(10000, 'Mestria'),
];

class NivelMestria {
  const NivelMestria({
    required this.patamarAtual,
    required this.horasAtuais,
    required this.proximoPatamar,
    required this.horasEmFalta,
    required this.progresso,
  });

  final Patamar patamarAtual;
  final double horasAtuais;

  /// `null` quando já atingiu o último patamar da escala.
  final Patamar? proximoPatamar;
  final double horasEmFalta;

  /// Progresso (0 a 1) entre [patamarAtual] e [proximoPatamar].
  final double progresso;
}

NivelMestria calcularNivelMestria(int totalSegundos) {
  final horas = totalSegundos / 3600;

  var indice = 0;
  for (var i = 0; i < escalaMestria.length; i++) {
    if (horas >= escalaMestria[i].horas) {
      indice = i;
    } else {
      break;
    }
  }

  final atual = escalaMestria[indice];
  final proximo = indice + 1 < escalaMestria.length ? escalaMestria[indice + 1] : null;

  if (proximo == null) {
    return NivelMestria(
      patamarAtual: atual,
      horasAtuais: horas,
      proximoPatamar: null,
      horasEmFalta: 0,
      progresso: 1,
    );
  }

  final intervalo = proximo.horas - atual.horas;
  final percorrido = horas - atual.horas;

  return NivelMestria(
    patamarAtual: atual,
    horasAtuais: horas,
    proximoPatamar: proximo,
    horasEmFalta: proximo.horas - horas,
    progresso: intervalo <= 0 ? 1 : (percorrido / intervalo).clamp(0, 1),
  );
}

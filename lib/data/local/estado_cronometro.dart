import 'package:isar_community/isar.dart';

part 'estado_cronometro.g.dart';

enum EstadoExecucao { emExecucao, pausado }

/// Estado persistido de um cronómetro ativo. Fonte de verdade é sempre um
/// timestamp, nunca uma contagem em memória — assim sobrevive a app
/// morta/reiniciada em segundo plano (ver plano, secção 4).
@collection
class EstadoCronometro {
  Id id = Isar.autoIncrement;

  /// Único por hobby — permite N hobbies com cronómetro ativo em simultâneo.
  @Index(unique: true)
  late int hobbyId;

  /// Momento em que esta sessão começou, nunca alterado por pausar/retomar.
  /// É o `inicio` guardado na [SessaoRegistada] quando o cronómetro parar.
  late DateTime inicioSessao;

  /// Momento do último "play"; `null` enquanto pausado.
  DateTime? timestampInicio;

  /// Soma de todos os troços já pausados/parados.
  int duracaoAcumuladaSegundos = 0;

  @Enumerated(EnumType.name)
  EstadoExecucao estado = EstadoExecucao.pausado;
}

extension EstadoCronometroElapsed on EstadoCronometro {
  /// Duração total decorrida, recalculada a partir do timestamp — nunca
  /// deve ser lida de uma contagem acumulada em memória.
  int elapsedSegundos([DateTime? agora]) {
    if (estado == EstadoExecucao.emExecucao && timestampInicio != null) {
      final momento = agora ?? DateTime.now();
      return duracaoAcumuladaSegundos + momento.difference(timestampInicio!).inSeconds;
    }
    return duracaoAcumuladaSegundos;
  }
}

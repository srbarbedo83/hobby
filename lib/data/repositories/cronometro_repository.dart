import '../local/estado_cronometro.dart';

abstract class CronometroRepository {
  Stream<EstadoCronometro?> watchPorHobby(int hobbyId);

  Future<void> iniciar(int hobbyId);

  Future<void> pausar(int hobbyId);

  Future<void> retomar(int hobbyId);

  /// Remove o estado ativo do hobby e devolve o que tinha antes de ser
  /// removido (ou `null` se não havia cronómetro ativo).
  Future<EstadoCronometro?> remover(int hobbyId);
}

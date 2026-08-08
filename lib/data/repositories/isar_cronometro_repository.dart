import 'package:isar_community/isar.dart';

import '../local/estado_cronometro.dart';
import 'cronometro_repository.dart';

class IsarCronometroRepository implements CronometroRepository {
  IsarCronometroRepository(this._isar);

  final Isar _isar;

  @override
  Stream<EstadoCronometro?> watchPorHobby(int hobbyId) {
    return _isar.estadoCronometros
        .filter()
        .hobbyIdEqualTo(hobbyId)
        .watch(fireImmediately: true)
        .map((lista) => lista.isEmpty ? null : lista.first);
  }

  @override
  Future<void> iniciar(int hobbyId) async {
    await _isar.writeTxn(() async {
      final agora = DateTime.now();
      final estado = EstadoCronometro()
        ..hobbyId = hobbyId
        ..inicioSessao = agora
        ..timestampInicio = agora
        ..duracaoAcumuladaSegundos = 0
        ..estado = EstadoExecucao.emExecucao;
      await _isar.estadoCronometros.put(estado);
    });
  }

  @override
  Future<void> pausar(int hobbyId) async {
    await _isar.writeTxn(() async {
      final estado = await _buscar(hobbyId);
      if (estado == null || estado.estado != EstadoExecucao.emExecucao) return;
      estado
        ..duracaoAcumuladaSegundos = estado.elapsedSegundos()
        ..timestampInicio = null
        ..estado = EstadoExecucao.pausado;
      await _isar.estadoCronometros.put(estado);
    });
  }

  @override
  Future<void> retomar(int hobbyId) async {
    await _isar.writeTxn(() async {
      final estado = await _buscar(hobbyId);
      if (estado == null || estado.estado != EstadoExecucao.pausado) return;
      estado
        ..timestampInicio = DateTime.now()
        ..estado = EstadoExecucao.emExecucao;
      await _isar.estadoCronometros.put(estado);
    });
  }

  @override
  Future<EstadoCronometro?> remover(int hobbyId) async {
    return _isar.writeTxn(() async {
      final estado = await _buscar(hobbyId);
      if (estado == null) return null;
      await _isar.estadoCronometros.delete(estado.id);
      return estado;
    });
  }

  Future<EstadoCronometro?> _buscar(int hobbyId) {
    return _isar.estadoCronometros.filter().hobbyIdEqualTo(hobbyId).findFirst();
  }
}

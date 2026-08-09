import 'package:isar_community/isar.dart';

import '../local/sessao_registada.dart';
import 'sessao_repository.dart';

class IsarSessaoRepository implements SessaoRepository {
  IsarSessaoRepository(this._isar);

  final Isar _isar;

  @override
  Future<int> guardar(SessaoRegistada sessao) {
    return _isar.writeTxn(() => _isar.sessaoRegistadas.put(sessao));
  }

  @override
  Stream<List<SessaoRegistada>> watchPorHobby(int hobbyId) {
    return _isar.sessaoRegistadas
        .filter()
        .hobbyIdEqualTo(hobbyId)
        .sortByInicio()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> atualizarNota(int sessaoId, String nota) async {
    await _isar.writeTxn(() async {
      final sessao = await _isar.sessaoRegistadas.get(sessaoId);
      if (sessao == null) return;
      sessao.nota = nota;
      await _isar.sessaoRegistadas.put(sessao);
    });
  }

  @override
  Future<void> apagar(int sessaoId) async {
    await _isar.writeTxn(() => _isar.sessaoRegistadas.delete(sessaoId));
  }
}

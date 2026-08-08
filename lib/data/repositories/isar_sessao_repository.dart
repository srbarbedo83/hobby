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
}

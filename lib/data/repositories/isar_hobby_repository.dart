import 'package:isar_community/isar.dart';

import '../local/hobby.dart';
import 'hobby_repository.dart';

class IsarHobbyRepository implements HobbyRepository {
  IsarHobbyRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Hobby>> watchAtivos() {
    return _isar.hobbys
        .filter()
        .ativoEqualTo(true)
        .sortByNome()
        .watch(fireImmediately: true);
  }

  @override
  Future<Hobby?> obterPorId(int id) => _isar.hobbys.get(id);

  @override
  Future<int> guardar(Hobby hobby) {
    return _isar.writeTxn(() => _isar.hobbys.put(hobby));
  }

  @override
  Future<void> arquivar(int id) async {
    await _isar.writeTxn(() async {
      final hobby = await _isar.hobbys.get(id);
      if (hobby == null) return;
      hobby.ativo = false;
      await _isar.hobbys.put(hobby);
    });
  }
}

import 'package:isar_community/isar.dart';

import '../local/livro.dart';
import 'livro_repository.dart';

class IsarLivroRepository implements LivroRepository {
  IsarLivroRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Livro>> watchPorHobby(int hobbyId) {
    return _isar.livros
        .filter()
        .hobbyIdEqualTo(hobbyId)
        .sortByCriadoEmDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<int> guardar(Livro livro) {
    return _isar.writeTxn(() => _isar.livros.put(livro));
  }

  @override
  Future<void> apagar(int livroId) async {
    await _isar.writeTxn(() => _isar.livros.delete(livroId));
  }
}

import '../local/livro.dart';

abstract class LivroRepository {
  Stream<List<Livro>> watchPorHobby(int hobbyId);

  Future<int> guardar(Livro livro);

  Future<void> apagar(int livroId);
}

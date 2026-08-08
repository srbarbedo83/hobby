import '../local/hobby.dart';

/// Interface fina sobre a persistência de [Hobby] — os ecrãs dependem
/// só disto, nunca do Isar diretamente, para poderem ser testados com
/// uma implementação falsa em vez de abrir uma base de dados real.
abstract class HobbyRepository {
  Stream<List<Hobby>> watchAtivos();

  Future<Hobby?> obterPorId(int id);

  /// Cria ou atualiza consoante `hobby.id` já exista. Devolve o id gravado.
  Future<int> guardar(Hobby hobby);

  Future<void> arquivar(int id);
}

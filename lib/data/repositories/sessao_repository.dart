import '../local/sessao_registada.dart';

abstract class SessaoRepository {
  Future<int> guardar(SessaoRegistada sessao);

  /// Todas as sessões de um hobby, ordenadas por [SessaoRegistada.inicio] —
  /// base do heatmap e das estatísticas no ecrã de detalhe.
  Stream<List<SessaoRegistada>> watchPorHobby(int hobbyId);
}

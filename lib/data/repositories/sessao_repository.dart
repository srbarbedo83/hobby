import '../local/sessao_registada.dart';

abstract class SessaoRepository {
  Future<int> guardar(SessaoRegistada sessao);

  /// Todas as sessões de um hobby, ordenadas por [SessaoRegistada.inicio] —
  /// base do heatmap e das estatísticas no ecrã de detalhe.
  Stream<List<SessaoRegistada>> watchPorHobby(int hobbyId);

  /// Anexa uma nota a uma sessão já gravada — usado quando o cronómetro
  /// pára e o utilizador só decide adicionar a nota depois, no snackbar.
  Future<void> atualizarNota(int sessaoId, String nota);

  Future<void> apagar(int sessaoId);
}

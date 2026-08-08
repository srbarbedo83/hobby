import '../local/sessao_registada.dart';

abstract class SessaoRepository {
  Future<int> guardar(SessaoRegistada sessao);
}

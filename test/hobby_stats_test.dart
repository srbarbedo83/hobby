import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/features/hobby_detail/hobby_stats.dart';

SessaoRegistada _sessao({required DateTime inicio, required int segundos}) {
  return SessaoRegistada()
    ..hobbyId = 1
    ..inicio = inicio
    ..duracaoSegundos = segundos
    ..origem = OrigemSessao.manual;
}

void main() {
  group('HobbyStats.calcular', () {
    test('devolve tudo a zero sem sessões', () {
      final stats = HobbyStats.calcular([]);

      expect(stats.totalSegundos, 0);
      expect(stats.mediaSemanalSegundos, 0);
      expect(stats.sessaoMaisLongaSegundos, 0);
      expect(stats.numeroSessoes, 0);
    });

    test('soma o total e encontra a sessão mais longa', () {
      final agora = DateTime.now();
      final stats = HobbyStats.calcular([
        _sessao(inicio: agora, segundos: 600),
        _sessao(inicio: agora, segundos: 1800),
        _sessao(inicio: agora, segundos: 300),
      ]);

      expect(stats.totalSegundos, 2700);
      expect(stats.sessaoMaisLongaSegundos, 1800);
      expect(stats.numeroSessoes, 3);
    });

    test('média semanal usa a data da primeira sessão, não a de hoje', () {
      final duasSemanasAtras = DateTime.now().subtract(const Duration(days: 14));
      final stats = HobbyStats.calcular([
        _sessao(inicio: duasSemanasAtras, segundos: 3600),
      ]);

      // 15 dias desde a primeira sessão -> arredonda para 3 semanas.
      expect(stats.mediaSemanalSegundos, 1200);
    });
  });
}

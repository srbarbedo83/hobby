import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/features/hobby_detail/hobby_stats.dart';

// Quarta-feira fixa: 1 jan 2024 é segunda, logo esta semana vai de
// 1 (segunda) a 7 (domingo) de janeiro de 2024.
final _quartaFeira = DateTime(2024, 1, 3);
final _segundaFeira = DateTime(2024, 1, 1);
final _semanaAnterior = DateTime(2023, 12, 25);

SessaoRegistada _sessao({
  required DateTime inicio,
  required int segundos,
  OrigemSessao origem = OrigemSessao.manual,
}) {
  return SessaoRegistada()
    ..hobbyId = 1
    ..inicio = inicio
    ..duracaoSegundos = segundos
    ..origem = origem;
}

void main() {
  group('HobbyStats.calcular', () {
    test('devolve tudo a zero sem sessões', () {
      final stats = HobbyStats.calcular([]);

      expect(stats.totalSegundos, 0);
      expect(stats.mediaSemanalSegundos, 0);
      expect(stats.mediaPorSessaoSegundos, 0);
      expect(stats.sessaoMaisLongaSegundos, 0);
      expect(stats.sessaoMaisCurtaSegundos, 0);
      expect(stats.numeroSessoes, 0);
      expect(stats.numeroSessoesCronometro, 0);
      expect(stats.numeroSessoesManual, 0);
      expect(stats.diasComSessoes, 0);
      expect(stats.ultimaSessao, isNull);
    });

    test('soma o total, e encontra a sessão mais longa e a mais curta', () {
      final stats = HobbyStats.calcular([
        _sessao(inicio: _quartaFeira, segundos: 600),
        _sessao(inicio: _quartaFeira, segundos: 1800),
        _sessao(inicio: _quartaFeira, segundos: 300),
      ]);

      expect(stats.totalSegundos, 2700);
      expect(stats.sessaoMaisLongaSegundos, 1800);
      expect(stats.sessaoMaisCurtaSegundos, 300);
      expect(stats.mediaPorSessaoSegundos, 900);
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

    test('esta semana só soma sessões desde segunda-feira da semana corrente', () {
      final stats = HobbyStats.calcular(
        [
          _sessao(inicio: _segundaFeira, segundos: 300),
          _sessao(inicio: _semanaAnterior, segundos: 900),
        ],
        agora: _quartaFeira,
      );

      expect(stats.estaSemanaSegundos, 300);
      expect(stats.totalSegundos, 1200);
    });

    test('este mês só soma sessões do mês corrente', () {
      final agora = DateTime(2024, 1, 15);
      final stats = HobbyStats.calcular(
        [
          _sessao(inicio: DateTime(2024, 1, 5), segundos: 600),
          _sessao(inicio: DateTime(2023, 12, 20), segundos: 1200),
        ],
        agora: agora,
      );

      expect(stats.esteMesSegundos, 600);
      expect(stats.totalSegundos, 1800);
    });

    test('conta sessões por origem', () {
      final stats = HobbyStats.calcular([
        _sessao(inicio: _quartaFeira, segundos: 600, origem: OrigemSessao.manual),
        _sessao(inicio: _quartaFeira, segundos: 600, origem: OrigemSessao.manual),
        _sessao(inicio: _quartaFeira, segundos: 600, origem: OrigemSessao.cronometro),
      ]);

      expect(stats.numeroSessoesManual, 2);
      expect(stats.numeroSessoesCronometro, 1);
    });

    test('dias com sessões conta dias distintos, não o nº de sessões', () {
      final stats = HobbyStats.calcular([
        _sessao(inicio: _quartaFeira, segundos: 300),
        _sessao(inicio: _quartaFeira, segundos: 300),
        _sessao(inicio: _segundaFeira, segundos: 300),
      ]);

      expect(stats.numeroSessoes, 3);
      expect(stats.diasComSessoes, 2);
    });

    test('última sessão é a mais recente, não a última da lista', () {
      final maisRecente = _sessao(inicio: _quartaFeira, segundos: 300);
      final stats = HobbyStats.calcular([
        maisRecente,
        _sessao(inicio: _segundaFeira, segundos: 300),
      ]);

      expect(stats.ultimaSessao, maisRecente.inicio);
    });
  });
}

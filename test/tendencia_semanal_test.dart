import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/features/hobby_detail/tendencia_semanal.dart';

// Quarta-feira fixa: 1 jan 2024 é segunda, logo a semana atual vai de
// 1 (segunda) a 7 (domingo) de janeiro de 2024.
final _quartaFeira = DateTime(2024, 1, 3);

SessaoRegistada _sessao(DateTime inicio, int segundos) {
  return SessaoRegistada()
    ..hobbyId = 1
    ..inicio = inicio
    ..duracaoSegundos = segundos
    ..origem = OrigemSessao.manual;
}

void main() {
  group('calcularTendenciaSemanal', () {
    test('sem sessões, histórico e projeção ficam todos a zero', () {
      final pontos = calcularTendenciaSemanal(
        [],
        semanasHistorico: 4,
        semanasProjecao: 2,
        agora: _quartaFeira,
      );

      expect(pontos, hasLength(6));
      expect(pontos.every((p) => p.minutos == 0), isTrue);
      expect(pontos.take(4).every((p) => !p.projetado), isTrue);
      expect(pontos.skip(4).every((p) => p.projetado), isTrue);
    });

    test('projeção usa a média das semanas já fechadas, não a semana atual (ainda a meio)', () {
      final pontos = calcularTendenciaSemanal(
        [
          _sessao(DateTime(2023, 12, 11), 3600), // há 3 semanas
          _sessao(DateTime(2023, 12, 18), 3600), // há 2 semanas
          _sessao(DateTime(2023, 12, 25), 3600), // semana passada
          // semana atual (2024-01-01) sem sessões — não deve entrar no momentum.
        ],
        semanasHistorico: 4,
        semanasProjecao: 2,
        janelaMomentum: 4,
        agora: _quartaFeira,
      );

      expect(pontos, hasLength(6));
      final historico = pontos.take(4).toList();
      expect(historico[0].minutos, 60);
      expect(historico[1].minutos, 60);
      expect(historico[2].minutos, 60);
      expect(historico[3].minutos, 0); // semana atual, ainda sem sessões

      final projecao = pontos.skip(4).toList();
      expect(projecao[0].minutos, 60);
      expect(projecao[1].minutos, 60);
      expect(projecao.every((p) => p.projetado), isTrue);
    });

    test('janela de momentum limita quantas semanas fechadas entram na média', () {
      final pontos = calcularTendenciaSemanal(
        [
          _sessao(DateTime(2023, 12, 4), 6000), // fora da janela de momentum
          _sessao(DateTime(2023, 12, 11), 1200),
          _sessao(DateTime(2023, 12, 18), 1200),
          _sessao(DateTime(2023, 12, 25), 1200),
        ],
        semanasHistorico: 5,
        semanasProjecao: 1,
        janelaMomentum: 3,
        agora: _quartaFeira,
      );

      final projecao = pontos.last;
      // Só as últimas 3 semanas fechadas (20min cada) entram na média — a de
      // 6000s/há 4 semanas fica de fora da janela.
      expect(projecao.minutos, 20);
    });
  });
}

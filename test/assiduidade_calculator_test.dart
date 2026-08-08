import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/data/local/hobby.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/features/adherence/assiduidade_calculator.dart';

// Quarta-feira fixa: 1 jan 2024 é segunda, então esta semana vai de
// 1 (segunda) a 7 (domingo) de janeiro de 2024.
final _quartaFeira = DateTime(2024, 1, 3);
final _segundaFeira = DateTime(2024, 1, 1);

Hobby _hobby(Meta? meta) {
  return Hobby()
    ..id = 1
    ..nome = 'Piano'
    ..icone = 0
    ..cor = 0xFF000000
    ..ativo = true
    ..criadoEm = DateTime(2023)
    ..meta = meta;
}

SessaoRegistada _sessao(DateTime inicio, int segundos) {
  return SessaoRegistada()
    ..hobbyId = 1
    ..inicio = inicio
    ..duracaoSegundos = segundos
    ..origem = OrigemSessao.manual;
}

void main() {
  group('calcularAssiduidade', () {
    test('devolve null sem meta definida', () {
      expect(calcularAssiduidade(_hobby(null), []), isNull);
    });

    test('meta semanal: compara o acumulado da semana com o alvo total, não proporcional', () {
      final meta = Meta()
        ..tipo = TipoMeta.semanal
        ..valorMinutos = 180;
      final sessoes = [_sessao(_quartaFeira, const Duration(minutes: 90).inSeconds)];

      final a = calcularAssiduidade(_hobby(meta), sessoes, agora: _quartaFeira)!;

      expect(a.unidade, UnidadeMeta.tempo);
      expect(a.percentagem, 50);
      expect(a.periodo, PeriodoAssiduidade.semana);
    });

    test('meta diária: alvo é o valor por dia vezes 7', () {
      final meta = Meta()
        ..tipo = TipoMeta.diaria
        ..valorMinutos = 30;
      // alvo da semana = 30*7 = 210 min; 105 min realizados = 50%.
      final sessoes = [_sessao(_quartaFeira, const Duration(minutes: 105).inSeconds)];

      final a = calcularAssiduidade(_hobby(meta), sessoes, agora: _quartaFeira)!;

      expect(a.alvo, const Duration(minutes: 210).inSeconds);
      expect(a.percentagem, 50);
    });

    test('meta por número de sessões semanal conta só sessões com duração > 0', () {
      final meta = Meta()
        ..tipo = TipoMeta.porNumeroSessoes
        ..numeroSessoes = 4
        ..periodicidade = Periodicidade.semanal;
      final sessoes = [
        _sessao(_segundaFeira, 600),
        _sessao(_quartaFeira, 600),
        _sessao(_quartaFeira, 0), // não deve contar
      ];

      final a = calcularAssiduidade(_hobby(meta), sessoes, agora: _quartaFeira)!;

      expect(a.unidade, UnidadeMeta.sessoes);
      expect(a.realizado, 2);
      expect(a.percentagem, 50);
      expect(a.periodo, PeriodoAssiduidade.semana);
    });

    test('meta por número de sessões diária só olha para hoje', () {
      final meta = Meta()
        ..tipo = TipoMeta.porNumeroSessoes
        ..numeroSessoes = 2
        ..periodicidade = Periodicidade.diario;
      final sessoes = [
        _sessao(_segundaFeira, 600), // fora do período (hoje é quarta)
        _sessao(_quartaFeira, 600),
      ];

      final a = calcularAssiduidade(_hobby(meta), sessoes, agora: _quartaFeira)!;

      expect(a.realizado, 1);
      expect(a.percentagem, 50);
      expect(a.periodo, PeriodoAssiduidade.dia);
    });

    test('permite ultrapassar 100%', () {
      final meta = Meta()
        ..tipo = TipoMeta.semanal
        ..valorMinutos = 60;
      final sessoes = [_sessao(_quartaFeira, const Duration(minutes: 90).inSeconds)];

      final a = calcularAssiduidade(_hobby(meta), sessoes, agora: _quartaFeira)!;

      expect(a.percentagem, 150);
    });
  });
}

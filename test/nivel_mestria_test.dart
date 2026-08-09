import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/features/hobby_detail/nivel_mestria.dart';

int _horas(int h) => h * 3600;

void main() {
  group('calcularNivelMestria', () {
    test('0h começa em Iniciante, a caminho de Iniciante-intermédio (300h)', () {
      final nivel = calcularNivelMestria(0);

      expect(nivel.patamarAtual.nome, 'Iniciante');
      expect(nivel.proximoPatamar?.nome, 'Iniciante-intermédio');
      expect(nivel.horasEmFalta, 300);
      expect(nivel.progresso, 0);
    });

    test('100h ainda em Iniciante, faltam 200h para os 300h seguintes', () {
      final nivel = calcularNivelMestria(_horas(100));

      expect(nivel.patamarAtual.nome, 'Iniciante');
      expect(nivel.proximoPatamar?.horas, 300);
      expect(nivel.horasEmFalta, 200);
      expect(nivel.progresso, closeTo(100 / 300, 0.001));
    });

    test('300h sobe para Iniciante-intermédio, a caminho de Autónomo (400h)', () {
      final nivel = calcularNivelMestria(_horas(300));

      expect(nivel.patamarAtual.nome, 'Iniciante-intermédio');
      expect(nivel.proximoPatamar?.nome, 'Autónomo');
      expect(nivel.horasEmFalta, 100);
    });

    test('900h atinge Bom', () {
      final nivel = calcularNivelMestria(_horas(900));

      expect(nivel.patamarAtual.nome, 'Bom');
      expect(nivel.proximoPatamar?.nome, 'Muito bom');
    });

    test('10000h ou mais atinge Mestria sem próximo patamar', () {
      final nivel = calcularNivelMestria(_horas(15000));

      expect(nivel.patamarAtual.nome, 'Mestria');
      expect(nivel.proximoPatamar, isNull);
      expect(nivel.progresso, 1);
    });
  });
}

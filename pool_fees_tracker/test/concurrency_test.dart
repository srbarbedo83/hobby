import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/concurrency.dart';

void main() {
  group('mapWithConcurrency', () {
    test('devolve os resultados na mesma ordem dos items de entrada', () async {
      final results = await mapWithConcurrency<int, int>(
        [1, 2, 3, 4, 5],
        (item) async => item * 10,
        maxConcurrent: 2,
      );
      expect(results, [10, 20, 30, 40, 50]);
    });

    test('nunca corre mais que maxConcurrent ao mesmo tempo', () async {
      var concurrent = 0;
      var maxSeen = 0;

      await mapWithConcurrency<int, int>(
        List.generate(10, (i) => i),
        (item) async {
          concurrent++;
          if (concurrent > maxSeen) maxSeen = concurrent;
          await Future.delayed(const Duration(milliseconds: 5));
          concurrent--;
          return item;
        },
        maxConcurrent: 3,
      );

      expect(maxSeen, lessThanOrEqualTo(3));
      // Confirma que corre mesmo em paralelo (não cai para 1 a 1).
      expect(maxSeen, greaterThan(1));
    });

    test('lista vazia devolve lista vazia sem chamar action', () async {
      var calls = 0;
      final results = await mapWithConcurrency<int, int>([], (item) async {
        calls++;
        return item;
      });
      expect(results, isEmpty);
      expect(calls, 0);
    });

    test('maxConcurrent maior que o número de items não rebenta', () async {
      final results = await mapWithConcurrency<int, int>(
        [1, 2],
        (item) async => item,
        maxConcurrent: 10,
      );
      expect(results, [1, 2]);
    });
  });
}

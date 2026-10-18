import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/calc/staleness.dart';

void main() {
  final now = DateTime(2026, 2, 1, 12);

  test('null lastUpdatedAt nunca é obsoleto (ainda não carregou)', () {
    expect(
      isDataStale(lastUpdatedAt: null, refreshIntervalSeconds: 30, now: now),
      isFalse,
    );
  });

  test('atualizado há pouco não é obsoleto', () {
    expect(
      isDataStale(
        lastUpdatedAt: now.subtract(const Duration(seconds: 10)),
        refreshIntervalSeconds: 30,
        now: now,
      ),
      isFalse,
    );
  });

  test('sem atualizar há muito mais que 3x o intervalo é obsoleto', () {
    expect(
      isDataStale(
        lastUpdatedAt: now.subtract(const Duration(minutes: 10)),
        refreshIntervalSeconds: 30,
        now: now,
      ),
      isTrue,
    );
  });

  test('threshold tem um mínimo de 2 minutos mesmo com intervalo curto', () {
    expect(
      isDataStale(
        lastUpdatedAt: now.subtract(const Duration(seconds: 90)),
        refreshIntervalSeconds: 5,
        now: now,
      ),
      isFalse,
    );
  });
}

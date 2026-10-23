/// Corre [action] para cada item de [items], mas nunca mais do que
/// [maxConcurrent] ao mesmo tempo — em vez de um `Future.wait` que dispara
/// tudo de uma vez. Confirmado ao vivo que isso é preciso: uma wallet com
/// 81 posições v4 no Arbitrum disparava ~250 pedidos RPC em simultâneo
/// (3 por posição), e a Alchemy (plano gratuito) devolvia HTTP 429
/// ("exceeded its compute units per second capacity") para a maioria —
/// não porque o RPC estivesse errado, só porque a rajada era grande
/// demais.
Future<List<R>> mapWithConcurrency<T, R>(
  List<T> items,
  Future<R> Function(T item) action, {
  int maxConcurrent = 6,
}) async {
  final results = List<R?>.filled(items.length, null);
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      final i = nextIndex;
      if (i >= items.length) return;
      nextIndex++;
      results[i] = await action(items[i]);
    }
  }

  final workerCount = maxConcurrent < items.length
      ? maxConcurrent
      : items.length;
  await Future.wait(List.generate(workerCount, (_) => worker()));
  return results.cast<R>();
}

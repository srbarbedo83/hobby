import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/local/fee_snapshot.dart';
import '../data/local/settings_service.dart';
import '../data/repositories/demo_pool_fees_repository.dart';
import '../data/repositories/isar_wallet_repository.dart';
import '../data/repositories/live_pool_fees_repository.dart';
import '../data/repositories/pool_fees_repository.dart';
import '../data/repositories/wallet_repository.dart';

/// Sobreposto em `main()` com a instância já aberta.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider tem de ser sobreposto em main()');
});

/// Sobreposto em `main()` com a instância já carregada.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(
    'settingsServiceProvider tem de ser sobreposto em main()',
  );
});

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsServiceProvider).load();

  Future<void> update(AppSettings Function(AppSettings current) updater) async {
    final next = updater(state);
    state = next;
    await ref.read(settingsServiceProvider).save(next);
  }
}

final appSettingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return IsarWalletRepository(ref.watch(isarProvider));
});

/// Escolhe a implementação segundo as definições: Demo (sintético, sem
/// rede) ou Live (subgraph Uniswap v3 + fórmula de fees on-chain). Troca de
/// `dataSourceMode` recria o repositório — por isso é mantido vivo durante
/// toda a vida da app em vez de ser recriado a cada rebuild não relacionado.
final poolFeesRepositoryProvider = Provider<PoolFeesRepository>((ref) {
  final settings = ref.watch(appSettingsProvider);

  final PoolFeesRepository repo;
  if (settings.dataSourceMode == DataSourceMode.live &&
      settings.isLiveModeReady) {
    repo = LivePoolFeesRepository(
      chain: settings.chain,
      apiKey: settings.subgraphApiKey,
      walletRepository: ref.watch(walletRepositoryProvider),
      isar: ref.watch(isarProvider),
    );
  } else {
    repo = DemoPoolFeesRepository();
  }
  repo.startAutoRefresh(Duration(seconds: settings.refreshIntervalSeconds));
  ref.onDispose(repo.dispose);
  return repo;
});

final positionsStreamProvider = StreamProvider((ref) {
  return ref.watch(poolFeesRepositoryProvider).watchPositions();
});

/// Histórico de fees de todas as posições conhecidas, por `positionKey`.
/// Fonte única para o agregado do dashboard, as sparklines das listas, e o
/// gráfico de barras do ecrã de detalhe — recalcula sempre que
/// [positionsStreamProvider] emite (live tick ou refresh).
final walletsProvider = FutureProvider(
  (ref) => ref.watch(walletRepositoryProvider).getAll(),
);

final allFeeSnapshotsProvider = FutureProvider<Map<String, List<FeeSnapshot>>>((
  ref,
) async {
  final positions = ref.watch(positionsStreamProvider).value ?? const [];
  final repo = ref.watch(poolFeesRepositoryProvider);
  final entries = await Future.wait(
    positions.map(
      (p) async =>
          MapEntry(p.positionKey, await repo.getFeeSnapshots(p.positionKey)),
    ),
  );
  return Map.fromEntries(entries);
});

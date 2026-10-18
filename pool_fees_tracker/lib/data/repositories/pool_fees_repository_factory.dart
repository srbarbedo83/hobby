import 'package:isar_community/isar.dart';

import '../local/settings_service.dart';
import 'demo_pool_fees_repository.dart';
import 'live_pool_fees_repository.dart';
import 'pool_fees_repository.dart';
import 'wallet_repository.dart';

/// Escolhe Demo ou Live segundo [settings] — usado tanto pelo provider do
/// app em primeiro plano como pela verificação de alertas em background
/// (`alert_check_worker.dart`), para não duplicar esta decisão.
PoolFeesRepository createPoolFeesRepository({
  required AppSettings settings,
  required WalletRepository walletRepository,
  required Isar isar,
}) {
  if (settings.dataSourceMode == DataSourceMode.live &&
      settings.isLiveModeReady) {
    return LivePoolFeesRepository(
      chains: settings.selectedChains.toList(),
      apiKey: settings.subgraphApiKey,
      walletRepository: walletRepository,
      isar: isar,
    );
  }
  return DemoPoolFeesRepository();
}

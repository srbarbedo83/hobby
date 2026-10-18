import 'package:isar_community/isar.dart';

import '../local/price_alert_rule.dart';

/// Leitura/escrita direta da regra de alerta de preço de uma posição — não
/// é parte de [PoolFeesRepository] porque não depende da fonte de dados
/// (Demo/Live), é só uma preferência do utilizador guardada em Isar, como
/// as wallets.
class PriceAlertRuleService {
  final Isar _isar;

  PriceAlertRuleService(this._isar);

  Future<PriceAlertRule?> get(String positionKey) {
    return _isar.priceAlertRules
        .filter()
        .positionKeyEqualTo(positionKey)
        .findFirst();
  }

  Future<void> set({
    required String positionKey,
    required int thresholdTick,
    required PriceAlertDirection direction,
  }) async {
    await _isar.writeTxn(() async {
      await _isar.priceAlertRules.put(
        PriceAlertRule()
          ..positionKey = positionKey
          ..thresholdTick = thresholdTick
          ..direction = direction
          ..enabled = true,
      );
    });
  }

  Future<void> clear(String positionKey) async {
    await _isar.writeTxn(() async {
      final existing = await get(positionKey);
      if (existing != null) await _isar.priceAlertRules.delete(existing.id);
    });
  }
}

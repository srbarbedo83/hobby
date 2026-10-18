import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'alert_log_entry.dart';
import 'alert_state.dart';
import 'fee_snapshot.dart';
import 'pool_position.dart';
import 'position_event.dart';
import 'price_alert_rule.dart';
import 'price_point.dart';
import 'wallet.dart';

/// Abre (ou devolve) a única instância local do Isar usada pela app.
///
/// Também é chamado a partir do isolate em background do Workmanager (ver
/// `alert_check_worker.dart`) — como corre num processo/isolate separado do
/// da app em primeiro plano, `_instance` lá começa `null` e abre a sua
/// própria ligação ao mesmo ficheiro; o Isar sabe lidar com isso com
/// segurança (é um dos casos de uso que suporta de propósito).
class IsarService {
  static Isar? _instance;

  static Future<Isar> open() async {
    final existing = _instance;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([
      WalletSchema,
      PoolPositionSchema,
      FeeSnapshotSchema,
      PositionEventSchema,
      AlertStateSchema,
      AlertLogEntrySchema,
      PricePointSchema,
      PriceAlertRuleSchema,
    ], directory: dir.path);
    _instance = isar;
    return isar;
  }
}

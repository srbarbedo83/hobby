import 'package:isar_community/isar.dart';

import '../../core/calc/range_health.dart';

part 'alert_state.g.dart';

/// Último estado conhecido de uma posição, para o detetor de alertas poder
/// comparar "o que mudou desde a última verificação" em vez de reavisar a
/// cada execução em background.
@collection
class AlertState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String positionKey;

  @Enumerated(EnumType.name)
  late RangeStatus lastRangeStatus;

  late double lastNotifiedFeesTotal;
}

import 'package:isar_community/isar.dart';

part 'alert_log_entry.g.dart';

enum AlertLogKind {
  outOfRange,
  outOfRangeDuration,
  feeMilestone,
  feeSlowdown,
  priceThreshold,
  concentrationRisk,
}

/// Um alerta já disparado — guardado para o ecrã de Alerts ter algo para
/// mostrar (um feed, não só um botão de configuração).
@collection
class AlertLogEntry {
  Id id = Isar.autoIncrement;

  late String positionKey;

  @Enumerated(EnumType.name)
  late AlertLogKind kind;

  late String title;
  late String body;

  @Index()
  late DateTime firedAt;
}

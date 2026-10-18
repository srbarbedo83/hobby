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

  /// Se a última verificação já tinha detetado "fees a abrandar" — para o
  /// alerta disparar só na transição (como `lastRangeStatus`), não a cada
  /// execução em background enquanto o abrandamento continuar.
  bool lastFeeSlowdownNotified = false;

  /// Só usado na linha reservada `positionKey == "__portfolio__"` (ver
  /// `detectConcentrationRisk`) — não é por posição, é da carteira toda.
  bool lastConcentrationRiskActive = false;

  /// Também só na linha `__portfolio__` — quando foi enviado o último
  /// resumo semanal (ver `shouldSendWeeklyDigest`). `null` = nunca enviado.
  DateTime? lastWeeklyDigestSentAt;
}

/// Chave reservada para a linha de `AlertState` que guarda estado a nível
/// da carteira toda (não de uma posição específica) — ver
/// `lastConcentrationRiskActive`.
const portfolioAlertStateKey = '__portfolio__';

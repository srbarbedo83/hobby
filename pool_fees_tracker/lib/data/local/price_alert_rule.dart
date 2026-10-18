import 'package:isar_community/isar.dart';

part 'price_alert_rule.g.dart';

enum PriceAlertDirection { above, below }

/// Alerta de preço definido pelo utilizador para uma posição — "avisa-me
/// quando o preço (token1 por token0) ficar acima/abaixo de X", separado
/// do range da própria posição. Uma regra por posição, para a UI de
/// Definir/Limpar ficar simples.
@collection
class PriceAlertRule {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String positionKey;

  /// Guardado como tick (não como preço) para a comparação com
  /// `currentTick` ser inteira e exata — ver `tickAtPrice`.
  late int thresholdTick;

  @Enumerated(EnumType.name)
  late PriceAlertDirection direction;

  bool enabled = true;

  /// Se a última verificação já tinha a condição cumprida — só dispara
  /// alerta na transição (mesmo padrão de `AlertState.lastRangeStatus`),
  /// e rearma se o preço voltar para o outro lado do threshold.
  bool lastTriggered = false;
}

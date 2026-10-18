import 'package:isar_community/isar.dart';

part 'position_event.g.dart';

enum PositionEventType { mint, increaseLiquidity, decreaseLiquidity, collect }

/// Um evento on-chain da posição: abertura, adição/remoção de liquidez, ou
/// uma recolha (`collect`) de fees. Alimenta a lista "Activity" do ecrã de
/// detalhe — pensado para responder a "quando é que eu toquei nesta
/// posição e por quanto".
@collection
class PositionEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late String positionKey;

  @Index()
  late DateTime timestamp;

  @Enumerated(EnumType.name)
  late PositionEventType type;

  /// Valor do evento em USD (depositado, retirado, ou fees recolhidas,
  /// segundo o [type]).
  late double amountUsd;

  /// Hash da transação, quando conhecido (modo Live) — usado para link
  /// para um explorador. `null` em modo Demo.
  String? txHash;
}

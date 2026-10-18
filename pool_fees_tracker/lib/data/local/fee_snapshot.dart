import 'package:isar_community/isar.dart';

part 'fee_snapshot.g.dart';

/// Um ponto no histórico de fees de uma posição: quanto foi ganho (em USD)
/// no intervalo entre este timestamp e o snapshot anterior. Agregar estes
/// deltas por hora/dia/semana/mês dá o gráfico de barras.
@collection
class FeeSnapshot {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('timestamp')])
  late String positionKey;

  late DateTime timestamp;

  late double feesUsdDelta;
}

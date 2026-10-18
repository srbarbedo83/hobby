import 'package:isar_community/isar.dart';

part 'price_point.g.dart';

/// Um ponto no histórico de preço de uma posição: o tick da pool nesse
/// momento (preço legível via `priceAtTick`, usando os decimais guardados
/// em `PoolPosition`). Alimenta o gráfico preço-vs-range, o detetor de
/// streak em range, e as estimativas de fees perdidas fora do range.
///
/// Em modo Live só é gravado a partir do momento em que a app liga (o
/// subgraph não é interrogado pelo histórico de tick antigo) — ver nota em
/// `live_pool_fees_repository.dart`. Em modo Demo é gerado sinteticamente
/// com o resto dos dados, já com alguns cruzamentos dentro/fora do range
/// para as funcionalidades que dependem disto terem algo realista para
/// mostrar.
@collection
class PricePoint {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('timestamp')])
  late String positionKey;

  late DateTime timestamp;

  late int tick;
}

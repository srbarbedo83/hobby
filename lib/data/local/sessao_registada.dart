import 'package:isar_community/isar.dart';

part 'sessao_registada.g.dart';

enum OrigemSessao { cronometro, manual }

@collection
class SessaoRegistada {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('inicio')])
  late int hobbyId;

  /// Base do heatmap e dos agregados por semana/mês.
  @Index()
  late DateTime inicio;

  /// Fonte de verdade para todas as somas — nunca recalculada a partir de outro campo.
  late int duracaoSegundos;

  @Enumerated(EnumType.name)
  late OrigemSessao origem;

  String? nota;
}

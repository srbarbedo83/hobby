import 'package:isar_community/isar.dart';

part 'hobby.g.dart';

/// Tipo de meta de assiduidade associada a um [Hobby].
enum TipoMeta { diaria, semanal, porNumeroSessoes }

/// Periodicidade usada por metas do tipo [TipoMeta.porNumeroSessoes].
enum Periodicidade { diario, semanal }

/// Meta de frequência/tempo de um hobby. Vive embutida em [Hobby.meta];
/// um hobby sem meta definida tem `meta == null`.
@embedded
class Meta {
  @Enumerated(EnumType.name)
  TipoMeta tipo = TipoMeta.semanal;

  /// Alvo de duração em minutos, usado por [TipoMeta.diaria] e [TipoMeta.semanal].
  int? valorMinutos;

  /// Alvo de nº de sessões, usado por [TipoMeta.porNumeroSessoes].
  int? numeroSessoes;

  @Enumerated(EnumType.name)
  Periodicidade periodicidade = Periodicidade.semanal;
}

@collection
class Hobby {
  Id id = Isar.autoIncrement;

  @Index()
  late String nome;

  /// Codepoint do [IconData] escolhido para o hobby.
  late int icone;

  /// Cor em ARGB (mesmo formato de [Color.value]).
  late int cor;

  /// Arquivado em vez de apagado, para não perder histórico de sessões.
  @Index()
  bool ativo = true;

  late DateTime criadoEm;

  Meta? meta;
}

import 'package:isar_community/isar.dart';

part 'livro.g.dart';

/// Específico para hobbies de leitura — não é um sistema genérico de
/// "itens por tipo de hobby", só livros mesmo.
@collection
class Livro {
  Id id = Isar.autoIncrement;

  @Index()
  late int hobbyId;

  late String titulo;

  String? autor;

  /// `null` enquanto ainda a ler.
  DateTime? dataConclusao;

  late DateTime criadoEm;
}

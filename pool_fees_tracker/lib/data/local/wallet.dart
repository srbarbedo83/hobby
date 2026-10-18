import 'package:isar_community/isar.dart';

part 'wallet.g.dart';

/// Endereço de carteira seguido pela app, em modo só-leitura.
@collection
class Wallet {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String address;

  late String label;

  late DateTime addedAt;
}

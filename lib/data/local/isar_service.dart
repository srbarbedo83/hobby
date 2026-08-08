import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'estado_cronometro.dart';
import 'hobby.dart';
import 'sessao_registada.dart';

/// Abre (ou devolve) a única instância local do Isar usada pela app.
class IsarService {
  static Isar? _instance;

  static Future<Isar> open() async {
    final existing = _instance;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [HobbySchema, EstadoCronometroSchema, SessaoRegistadaSchema],
      directory: dir.path,
    );
    _instance = isar;
    return isar;
  }
}

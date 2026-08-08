import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/repositories/hobby_repository.dart';
import '../data/repositories/isar_hobby_repository.dart';

/// Sobreposto em `main()` com a instância já aberta — abrir o Isar é
/// assíncrono e só acontece uma vez, antes de `runApp`.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider tem de ser sobreposto em main()');
});

/// Sobreponível diretamente nos testes com uma implementação falsa,
/// sem precisar de abrir um Isar real.
final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  return IsarHobbyRepository(ref.watch(isarProvider));
});

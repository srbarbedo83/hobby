import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../data/repositories/cronometro_repository.dart';
import '../data/repositories/hobby_repository.dart';
import '../data/repositories/isar_cronometro_repository.dart';
import '../data/repositories/isar_hobby_repository.dart';
import '../data/repositories/isar_sessao_repository.dart';
import '../data/repositories/sessao_repository.dart';

/// Sobreposto em `main()` com a instância já aberta — abrir o Isar é
/// assíncrono e só acontece uma vez, antes de `runApp`.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider tem de ser sobreposto em main()');
});

/// Sobreponíveis diretamente nos testes com implementações falsas, sem
/// precisar de abrir um Isar real.
final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  return IsarHobbyRepository(ref.watch(isarProvider));
});

final cronometroRepositoryProvider = Provider<CronometroRepository>((ref) {
  return IsarCronometroRepository(ref.watch(isarProvider));
});

final sessaoRepositoryProvider = Provider<SessaoRepository>((ref) {
  return IsarSessaoRepository(ref.watch(isarProvider));
});

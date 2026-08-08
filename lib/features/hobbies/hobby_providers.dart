import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/hobby.dart';

final hobbiesAtivosProvider = StreamProvider<List<Hobby>>((ref) {
  return ref.watch(hobbyRepositoryProvider).watchAtivos();
});

final hobbyByIdProvider = FutureProvider.family<Hobby?, int>((ref, id) {
  return ref.watch(hobbyRepositoryProvider).obterPorId(id);
});

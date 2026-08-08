import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/sessao_registada.dart';

final sessoesPorHobbyProvider = StreamProvider.family<List<SessaoRegistada>, int>((ref, hobbyId) {
  return ref.watch(sessaoRepositoryProvider).watchPorHobby(hobbyId);
});

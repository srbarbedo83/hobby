import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/local/estado_cronometro.dart';
import 'timer_controller.dart';

final cronometroPorHobbyProvider = StreamProvider.family<EstadoCronometro?, int>((ref, hobbyId) {
  return ref.watch(cronometroRepositoryProvider).watchPorHobby(hobbyId);
});

final timerControllerProvider = Provider<TimerController>((ref) {
  return TimerController(
    ref.watch(cronometroRepositoryProvider),
    ref.watch(sessaoRepositoryProvider),
  );
});

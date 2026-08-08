import '../../data/local/estado_cronometro.dart';
import '../../data/local/sessao_registada.dart';
import '../../data/repositories/cronometro_repository.dart';
import '../../data/repositories/sessao_repository.dart';

/// Coordena as duas coleções envolvidas em parar um cronómetro: remove o
/// [EstadoCronometro] e grava a [SessaoRegistada] correspondente.
class TimerController {
  TimerController(this._cronometroRepo, this._sessaoRepo);

  final CronometroRepository _cronometroRepo;
  final SessaoRepository _sessaoRepo;

  Future<void> iniciar(int hobbyId) => _cronometroRepo.iniciar(hobbyId);

  Future<void> pausar(int hobbyId) => _cronometroRepo.pausar(hobbyId);

  Future<void> retomar(int hobbyId) => _cronometroRepo.retomar(hobbyId);

  /// Termina o cronómetro e grava a sessão. Devolve a duração em segundos,
  /// ou `null` se não havia cronómetro ativo (ou a duração era zero).
  Future<int?> parar(int hobbyId) async {
    final estado = await _cronometroRepo.remover(hobbyId);
    if (estado == null) return null;

    final duracao = estado.elapsedSegundos();
    if (duracao <= 0) return null;

    await _sessaoRepo.guardar(
      SessaoRegistada()
        ..hobbyId = hobbyId
        ..inicio = estado.inicioSessao
        ..duracaoSegundos = duracao
        ..origem = OrigemSessao.cronometro,
    );
    return duracao;
  }
}

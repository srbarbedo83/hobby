import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritmo/app/app.dart';
import 'package:ritmo/core/providers.dart';
import 'package:ritmo/data/local/estado_cronometro.dart';
import 'package:ritmo/data/local/hobby.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/data/repositories/cronometro_repository.dart';
import 'package:ritmo/data/repositories/hobby_repository.dart';
import 'package:ritmo/data/repositories/sessao_repository.dart';

class _FakeHobbyRepository implements HobbyRepository {
  final List<Hobby> hobbies = [];

  @override
  Stream<List<Hobby>> watchAtivos() => Stream.value(hobbies);

  @override
  Future<Hobby?> obterPorId(int id) async =>
      hobbies.where((h) => h.id == id).firstOrNull;

  @override
  Future<int> guardar(Hobby hobby) async {
    hobbies.add(hobby);
    return hobby.id;
  }

  @override
  Future<void> arquivar(int id) async {
    hobbies.removeWhere((h) => h.id == id);
  }
}

/// Deixa o teste simular um cronómetro já com [backdate] decorrido, para
/// não depender de esperar segundos reais para acumular duração.
class _FakeCronometroRepository implements CronometroRepository {
  Duration backdate = Duration.zero;

  final Map<int, EstadoCronometro> _estados = {};
  final Map<int, StreamController<EstadoCronometro?>> _controllers = {};

  StreamController<EstadoCronometro?> _controllerFor(int hobbyId) =>
      _controllers.putIfAbsent(hobbyId, () => StreamController<EstadoCronometro?>.broadcast());

  @override
  Stream<EstadoCronometro?> watchPorHobby(int hobbyId) async* {
    yield _estados[hobbyId];
    yield* _controllerFor(hobbyId).stream;
  }

  @override
  Future<void> iniciar(int hobbyId) async {
    final agora = DateTime.now();
    final estado = EstadoCronometro()
      ..hobbyId = hobbyId
      ..inicioSessao = agora
      ..timestampInicio = agora.subtract(backdate)
      ..duracaoAcumuladaSegundos = 0
      ..estado = EstadoExecucao.emExecucao;
    _estados[hobbyId] = estado;
    _controllerFor(hobbyId).add(estado);
  }

  @override
  Future<void> pausar(int hobbyId) async {
    final estado = _estados[hobbyId];
    if (estado == null || estado.estado != EstadoExecucao.emExecucao) return;
    estado
      ..duracaoAcumuladaSegundos = estado.elapsedSegundos()
      ..timestampInicio = null
      ..estado = EstadoExecucao.pausado;
    _controllerFor(hobbyId).add(estado);
  }

  @override
  Future<void> retomar(int hobbyId) async {
    final estado = _estados[hobbyId];
    if (estado == null || estado.estado != EstadoExecucao.pausado) return;
    estado
      ..timestampInicio = DateTime.now()
      ..estado = EstadoExecucao.emExecucao;
    _controllerFor(hobbyId).add(estado);
  }

  @override
  Future<EstadoCronometro?> remover(int hobbyId) async {
    final estado = _estados.remove(hobbyId);
    _controllerFor(hobbyId).add(null);
    return estado;
  }
}

class _FakeSessaoRepository implements SessaoRepository {
  final List<SessaoRegistada> guardadas = [];

  @override
  Future<int> guardar(SessaoRegistada sessao) async {
    guardadas.add(sessao);
    return guardadas.length;
  }
}

void main() {
  testWidgets('mostra o estado vazio quando não há hobbies', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(_FakeHobbyRepository()),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Os teus hobbies'), findsOneWidget);
    expect(find.textContaining('Ainda não tens hobbies'), findsOneWidget);
  });

  testWidgets('inicia, pausa e termina um cronómetro, gravando a sessão', (tester) async {
    final hobbyRepo = _FakeHobbyRepository()
      ..hobbies.add(
        Hobby()
          ..id = 1
          ..nome = 'Piano'
          ..icone = Icons.piano.codePoint
          ..cor = 0xFF96691F
          ..ativo = true
          ..criadoEm = DateTime.now(),
      );
    final cronometroRepo = _FakeCronometroRepository()..backdate = const Duration(seconds: 65);
    final sessaoRepo = _FakeSessaoRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(cronometroRepo),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.textContaining('1:0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(sessaoRepo.guardadas, hasLength(1));
    expect(sessaoRepo.guardadas.single.hobbyId, 1);
    expect(sessaoRepo.guardadas.single.origem, OrigemSessao.cronometro);
    expect(sessaoRepo.guardadas.single.duracaoSegundos, greaterThanOrEqualTo(65));

    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
  });
}

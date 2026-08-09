import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart' show Isar;

import 'package:ritmo/app/app.dart';
import 'package:ritmo/core/providers.dart';
import 'package:ritmo/data/local/estado_cronometro.dart';
import 'package:ritmo/data/local/hobby.dart';
import 'package:ritmo/data/local/sessao_registada.dart';
import 'package:ritmo/data/repositories/cronometro_repository.dart';
import 'package:ritmo/data/repositories/hobby_repository.dart';
import 'package:ritmo/data/repositories/sessao_repository.dart';

/// Reproduz o upsert-por-id do Isar real: um `id` novo (sentinel
/// `Isar.autoIncrement`) recebe um id a sério; um `id` já existente
/// substitui o registo em vez de duplicar — foi precisamente a ausência
/// desta semântica na fake anterior que deixou passar um bug em que criar
/// um segundo hobby sobrepunha sempre o primeiro.
class _FakeHobbyRepository implements HobbyRepository {
  final List<Hobby> hobbies = [];
  int _proximoId = 1;
  final _controller = StreamController<List<Hobby>>.broadcast();

  List<Hobby> get _ativos => hobbies.where((h) => h.ativo).toList();

  @override
  Stream<List<Hobby>> watchAtivos() async* {
    yield _ativos;
    yield* _controller.stream;
  }

  @override
  Future<Hobby?> obterPorId(int id) async =>
      hobbies.where((h) => h.id == id).firstOrNull;

  @override
  Future<int> guardar(Hobby hobby) async {
    if (hobby.id == Isar.autoIncrement) {
      hobby.id = _proximoId++;
    }
    final indice = hobbies.indexWhere((h) => h.id == hobby.id);
    if (indice >= 0) {
      hobbies[indice] = hobby;
    } else {
      hobbies.add(hobby);
    }
    _controller.add(_ativos);
    return hobby.id;
  }

  @override
  Future<void> arquivar(int id) async {
    hobbies.removeWhere((h) => h.id == id);
    _controller.add(_ativos);
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
  int _proximoId = 1;
  final _controller = StreamController<void>.broadcast();

  @override
  Future<int> guardar(SessaoRegistada sessao) async {
    if (sessao.id == Isar.autoIncrement) {
      sessao.id = _proximoId++;
    }
    final indice = guardadas.indexWhere((s) => s.id == sessao.id);
    if (indice >= 0) {
      guardadas[indice] = sessao;
    } else {
      guardadas.add(sessao);
    }
    _controller.add(null);
    return sessao.id;
  }

  @override
  Stream<List<SessaoRegistada>> watchPorHobby(int hobbyId) async* {
    yield guardadas.where((s) => s.hobbyId == hobbyId).toList();
    yield* _controller.stream.map((_) => guardadas.where((s) => s.hobbyId == hobbyId).toList());
  }

  @override
  Future<void> atualizarNota(int sessaoId, String nota) async {
    final sessao = guardadas.where((s) => s.id == sessaoId).firstOrNull;
    sessao?.nota = nota;
    _controller.add(null);
  }

  @override
  Future<void> apagar(int sessaoId) async {
    guardadas.removeWhere((s) => s.id == sessaoId);
    _controller.add(null);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_PT');
  });

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

  testWidgets('criar um segundo hobby não sobrepõe o primeiro', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(_FakeHobbyRepository()),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(_FakeSessaoRepository()),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> criarHobby(String nome) async {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), nome);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
    }

    await criarHobby('Piano');
    await criarHobby('Guitarra');

    expect(find.text('Piano'), findsOneWidget);
    expect(find.text('Guitarra'), findsOneWidget);
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

  testWidgets('regista um atalho manual de +15 min quando o cronómetro está parado', (tester) async {
    final hobbyRepo = _FakeHobbyRepository()
      ..hobbies.add(
        Hobby()
          ..id = 1
          ..nome = 'Leitura'
          ..icone = Icons.menu_book.codePoint
          ..cor = 0xFF2F6F5C
          ..ativo = true
          ..criadoEm = DateTime.now(),
      );
    final sessaoRepo = _FakeSessaoRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();

    expect(find.text('Registar tempo — Leitura'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Nota (opcional)'), 'capítulo 3');
    await tester.tap(find.text('+15 min'));
    await tester.pumpAndSettle();

    expect(sessaoRepo.guardadas, hasLength(1));
    expect(sessaoRepo.guardadas.single.hobbyId, 1);
    expect(sessaoRepo.guardadas.single.origem, OrigemSessao.manual);
    expect(sessaoRepo.guardadas.single.duracaoSegundos, const Duration(minutes: 15).inSeconds);
    expect(sessaoRepo.guardadas.single.nota, 'capítulo 3');
  });

  testWidgets('regista uma duração exata introduzida manualmente', (tester) async {
    final hobbyRepo = _FakeHobbyRepository()
      ..hobbies.add(
        Hobby()
          ..id = 1
          ..nome = 'Guitarra'
          ..icone = Icons.music_note.codePoint
          ..cor = 0xFF96691F
          ..ativo = true
          ..criadoEm = DateTime.now(),
      );
    final sessaoRepo = _FakeSessaoRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_time));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Horas'), '1');
    await tester.enterText(find.widgetWithText(TextField, 'Minutos'), '20');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(sessaoRepo.guardadas, hasLength(1));
    expect(sessaoRepo.guardadas.single.duracaoSegundos, const Duration(hours: 1, minutes: 20).inSeconds);
    expect(sessaoRepo.guardadas.single.origem, OrigemSessao.manual);
  });

  testWidgets('ecrã de detalhe mostra o heatmap e as estatísticas do hobby', (tester) async {
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
    final agora = DateTime.now();
    final sessaoRepo = _FakeSessaoRepository()
      ..guardadas.addAll([
        SessaoRegistada()
          ..hobbyId = 1
          ..inicio = agora
          ..duracaoSegundos = 1800
          ..origem = OrigemSessao.manual,
        SessaoRegistada()
          ..hobbyId = 1
          ..inicio = agora.subtract(const Duration(days: 10))
          ..duracaoSegundos = 3600
          ..origem = OrigemSessao.cronometro,
      ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Piano'));
    await tester.pumpAndSettle();

    expect(find.text('Estatísticas'), findsOneWidget);
    expect(find.text('1:30:00'), findsOneWidget); // total acumulado
    expect(find.text('45:00'), findsOneWidget); // média por semana
    expect(find.text('1:00:00'), findsOneWidget); // sessão mais longa
    expect(find.text('2'), findsOneWidget); // nº de sessões
  });

  testWidgets('ecrã de assiduidade mostra a percentagem cumprida da meta semanal', (tester) async {
    final hobbyRepo = _FakeHobbyRepository()
      ..hobbies.add(
        Hobby()
          ..id = 1
          ..nome = 'Piano'
          ..icone = Icons.piano.codePoint
          ..cor = 0xFF96691F
          ..ativo = true
          ..criadoEm = DateTime.now()
          ..meta = (Meta()
            ..tipo = TipoMeta.semanal
            ..valorMinutos = 180),
      );
    final sessaoRepo = _FakeSessaoRepository()
      ..guardadas.add(
        SessaoRegistada()
          ..hobbyId = 1
          ..inicio = DateTime.now()
          ..duracaoSegundos = const Duration(minutes: 90).inSeconds
          ..origem = OrigemSessao.manual,
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Assiduidade'));
    await tester.pumpAndSettle();

    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1:30:00 de 3:00:00 — esta semana'), findsOneWidget);
  });

  testWidgets('permite adicionar uma nota depois de parar o cronómetro', (tester) async {
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

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Adicionar nota'), findsOneWidget);
    await tester.tap(find.text('Adicionar nota'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'praticei escalas');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(sessaoRepo.guardadas, hasLength(1));
    expect(sessaoRepo.guardadas.single.nota, 'praticei escalas');
  });

  testWidgets('permite editar a duração de uma sessão já registada, seja cronómetro ou manual', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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
    final sessaoRepo = _FakeSessaoRepository()
      ..guardadas.add(
        SessaoRegistada()
          ..id = 1
          ..hobbyId = 1
          ..inicio = DateTime.now()
          ..duracaoSegundos = const Duration(minutes: 30).inSeconds
          ..origem = OrigemSessao.cronometro,
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Piano'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sessao_1')));
    await tester.pumpAndSettle();

    expect(find.text('Editar sessão'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Minutos'), '45');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(sessaoRepo.guardadas.single.duracaoSegundos, const Duration(minutes: 45).inSeconds);
  });

  testWidgets('permite apagar uma sessão a partir do editor', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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
    final sessaoRepo = _FakeSessaoRepository()
      ..guardadas.add(
        SessaoRegistada()
          ..id = 1
          ..hobbyId = 1
          ..inicio = DateTime.now()
          ..duracaoSegundos = const Duration(minutes: 30).inSeconds
          ..origem = OrigemSessao.manual,
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hobbyRepositoryProvider.overrideWithValue(hobbyRepo),
          cronometroRepositoryProvider.overrideWithValue(_FakeCronometroRepository()),
          sessaoRepositoryProvider.overrideWithValue(sessaoRepo),
        ],
        child: const RitmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Piano'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('sessao_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    expect(sessaoRepo.guardadas, isEmpty);
  });
}

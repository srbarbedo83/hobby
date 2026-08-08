import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritmo/app/app.dart';
import 'package:ritmo/core/providers.dart';
import 'package:ritmo/data/local/hobby.dart';
import 'package:ritmo/data/repositories/hobby_repository.dart';

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
}

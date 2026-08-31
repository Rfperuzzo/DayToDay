import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/app/app_dependencies.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_andriele/features/activities/domain/subtask.dart';
import 'package:rotina_andriele/features/activities/domain/subtask_repository.dart';
import 'package:rotina_andriele/features/activities/presentation/subtasks_sheet.dart';

void main() {
  testWidgets('adiciona e conclui subtarefa ligada à atividade', (
    tester,
  ) async {
    final repository = _MemorySubtasks();
    addTearDown(repository.close);
    final activity = Activity(
      id: 'treino',
      title: 'Treino',
      estimatedDuration: const Duration(minutes: 60),
      priority: ActivityPriority.normal,
      recurrence: OneOffRecurrence(DateTime.utc(2026, 8, 30, 10)),
      createdAtUtc: DateTime.utc(2026, 8, 29),
      updatedAtUtc: DateTime.utc(2026, 8, 29),
    );

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subtaskRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Scaffold(body: SubtasksSheet(activity: activity)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Separar os pesos');
    await tester.tap(find.byTooltip('Adicionar subtarefa'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Separar os pesos'), findsOneWidget);
    expect(find.text('0 de 1 etapas concluídas'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('1 de 1 etapas concluídas'), findsOneWidget);
    expect(repository.values.single.activityId, activity.id);
    expect(repository.values.single.isCompleted, isTrue);
    expect(tester.takeException(), isNull);
  });
}

final class _MemorySubtasks implements SubtaskRepository {
  final values = <Subtask>[];
  final _changes = StreamController<List<Subtask>>.broadcast();

  @override
  Future<void> delete(String subtaskId) async {
    values.removeWhere((item) => item.id == subtaskId);
    _emit();
  }

  @override
  Future<List<Subtask>> findForActivity(String activityId) async => values
      .where((item) => item.activityId == activityId)
      .toList(growable: false);

  @override
  Future<void> save(Subtask subtask) async {
    values
      ..removeWhere((item) => item.id == subtask.id)
      ..add(subtask);
    _emit();
  }

  @override
  Stream<List<Subtask>> watchForActivity(String activityId) async* {
    yield await findForActivity(activityId);
    yield* _changes.stream.map(
      (items) => items
          .where((item) => item.activityId == activityId)
          .toList(growable: false),
    );
  }

  void _emit() => _changes.add([...values]);

  Future<void> close() => _changes.close();
}

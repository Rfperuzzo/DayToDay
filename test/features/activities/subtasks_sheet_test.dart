import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/app/app_dependencies.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/activities/domain/subtask.dart';
import 'package:rotina_jhenifer/features/activities/domain/subtask_repository.dart';
import 'package:rotina_jhenifer/features/activities/presentation/subtasks_sheet.dart';

void main() {
  testWidgets('adiciona e conclui subtarefa ligada à atividade', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
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
    expect(find.bySemanticsLabel('Nova subtarefa'), findsOneWidget);
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
    semantics.dispose();
  });

  testWidgets('folha real permite adicionar com teclado e texto 2x em 320dp', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _MemorySubtasks();
    addTearDown(repository.close);
    final activity = Activity(
      id: 'ux',
      title: 'Uma atividade com nome extenso para verificar a composição',
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      recurrence: OneOffRecurrence(DateTime.utc(2026, 11, 14, 20)),
      createdAtUtc: DateTime.utc(2026),
      updatedAtUtc: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [subtaskRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              viewInsets: const EdgeInsets.only(bottom: 280),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (_) => SubtasksSheet(activity: activity),
                ),
                child: const Text('Abrir etapas'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir etapas'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('subtasks-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(find.byType(TextField), 'Revisar o material');
    await tester.ensureVisible(find.byTooltip('Adicionar subtarefa'));
    await tester.tap(find.byTooltip('Adicionar subtarefa'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(repository.values.single.title, 'Revisar o material');
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/core/time/clock.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/application/activity_manager.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_andriele/features/activities/domain/activity_recurrence_preset.dart';
import 'package:rotina_andriele/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_andriele/features/activities/presentation/activity_options_sheet.dart';

void main() {
  testWidgets('toque na opção retorna pedido de edição', (tester) async {
    ActivityOption? selected;
    final data = _Data();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selected = await showModalBottomSheet<ActivityOption>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => ActivityOptionsSheet(
                    activity: data.activity,
                    occurrence: data.occurrence,
                    timeZone: const _UtcTimeZone(),
                  ),
                );
              },
              child: const Text('Abrir opções'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir opções'));
    await tester.pumpAndSettle();
    expect(find.text('Editar nome ou horário'), findsOneWidget);
    expect(find.text('Subtarefas'), findsOneWidget);
    expect(find.text('Cancelar atividade'), findsOneWidget);
    await tester.tap(find.text('Editar nome ou horário'));
    await tester.pumpAndSettle();

    expect(selected, ActivityOption.edit);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formulário devolve nome e horário editados', (tester) async {
    ActivityEditDraft? draft;
    final data = _Data();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                draft = await showModalBottomSheet<ActivityEditDraft>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => EditActivitySheet(
                    activity: data.activity,
                    occurrence: data.occurrence,
                    timeZone: const _UtcTimeZone(),
                    clock: const _FixedClock(),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Treino de força');
    await tester.tap(find.text('Todo dia'));
    await tester.pump();
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    expect(draft?.title, 'Treino de força');
    expect(draft?.hour, 15);
    expect(draft?.minute, 0);
    expect(draft?.recurrence, ActivityRecurrencePreset.daily);
    expect(draft?.estimatedDuration, const Duration(minutes: 60));
    expect(tester.takeException(), isNull);
  });

  testWidgets('abertura pelo widget oferece conclusão direta', (tester) async {
    ActivityOption? selected;
    final data = _Data();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                selected = await showModalBottomSheet<ActivityOption>(
                  context: context,
                  builder: (context) => ActivityOptionsSheet(
                    activity: data.activity,
                    occurrence: data.occurrence,
                    timeZone: const _UtcTimeZone(),
                    showComplete: true,
                  ),
                );
              },
              child: const Text('Abrir pelo widget'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir pelo widget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir tarefa'));
    await tester.pumpAndSettle();

    expect(selected, ActivityOption.complete);
    expect(tester.takeException(), isNull);
  });
}

final class _Data {
  _Data()
    : activity = Activity(
        id: 'treino',
        title: 'Treino',
        estimatedDuration: const Duration(minutes: 60),
        priority: ActivityPriority.high,
        recurrence: OneOffRecurrence(DateTime.utc(2026, 8, 29, 15)),
        createdAtUtc: DateTime.utc(2026, 8, 28),
        updatedAtUtc: DateTime.utc(2026, 8, 28),
      ),
      occurrence = ActivityOccurrence(
        id: 'treino:1',
        activityId: 'treino',
        originalStartUtc: DateTime.utc(2026, 8, 29, 15),
        scheduledStartUtc: DateTime.utc(2026, 8, 29, 15),
        estimatedDuration: const Duration(minutes: 60),
        priority: ActivityPriority.high,
        status: OccurrenceStatus.scheduled,
      );

  final Activity activity;
  final ActivityOccurrence occurrence;
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 29, 12);
}

final class _UtcTimeZone implements TimeZoneService {
  const _UtcTimeZone();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) => DateTime.utc(
    localComponents.year,
    localComponents.month,
    localComponents.day,
    localComponents.hour,
    localComponents.minute,
  );

  @override
  DateTime toLocal(DateTime utc) {
    final value = utc.toUtc();
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
    );
  }
}

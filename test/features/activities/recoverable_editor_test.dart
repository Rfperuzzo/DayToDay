import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/application/schedule_availability.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/activities/presentation/activity_options_sheet.dart';
import 'package:rotina_jhenifer/main.dart';

final _at = DateTime.utc(2026, 11, 15, 12);
final _activity = Activity(
  id: 'reading',
  title: 'Ler',
  estimatedDuration: const Duration(minutes: 30),
  priority: ActivityPriority.normal,
  recurrence: OneOffRecurrence(_at),
  createdAtUtc: _at,
  updatedAtUtc: _at,
);
final _occurrence = ActivityOccurrence(
  id: 'reading:1',
  activityId: _activity.id,
  originalStartUtc: _at,
  scheduledStartUtc: _at,
  estimatedDuration: _activity.estimatedDuration,
  priority: _activity.priority,
  status: OccurrenceStatus.scheduled,
);
final _result = ActivityMutationResult(
  activity: _activity,
  affectedOccurrences: 1,
  generatedOccurrences: 1,
  alarmsSynchronized: true,
);

Widget _host(
  Future<ActivityMutationResult> Function(ActivityEditDraft) save,
  ValueChanged<ActivityMutationResult?> done,
) => DayToDayApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => FilledButton(
        onPressed: () async => done(
          await showModalBottomSheet<ActivityMutationResult>(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            builder: (_) => EditActivitySheet(
              activity: _activity,
              occurrence: _occurrence,
              timeZone: const _UtcZone(),
              clock: const _Clock(),
              onSave: save,
            ),
          ),
        ),
        child: const Text('Abrir editor'),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'conflito retém alterações e permite corrigir e tentar novamente',
    (tester) async {
      var calls = 0;
      ActivityEditDraft? saved;
      ActivityMutationResult? result;
      await tester.pumpWidget(
        _host((draft) async {
          calls++;
          saved = draft;
          if (calls == 1) {
            throw ScheduleConflictException(
              candidate: _occurrence,
              blocking: _occurrence,
            );
          }
          return _result;
        }, (value) => result = value),
      );
      await tester.tap(find.text('Abrir editor'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'Ler e fazer anotações',
      );
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(
        find.textContaining('Esse intervalo está ocupado'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Ler e fazer anotações',
      );
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(saved!.title, 'Ler e fazer anotações');
      expect(result, same(_result));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('gravação pendente impede voltar, fechar e salvar duas vezes', (
    tester,
  ) async {
    final pending = Completer<ActivityMutationResult>();
    var calls = 0;
    ActivityMutationResult? result;
    await tester.pumpWidget(
      _host((draft) {
        calls++;
        return pending.future;
      }, (value) => result = value),
    );
    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pump();
    expect(find.text('Salvando…'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find
                .ancestor(
                  of: find.byTooltip('Fechar'),
                  matching: find.byType(IconButton),
                )
                .first,
          )
          .onPressed,
      isNull,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Editar atividade'), findsOneWidget);
    expect(result, isNull);
    expect(calls, 1);
    pending.complete(_result);
    await tester.pumpAndSettle();
    expect(result, same(_result));
    expect(tester.takeException(), isNull);
  });
}

final class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 14, 12);
}

final class _UtcZone implements TimeZoneService {
  const _UtcZone();
  @override
  DateTime toLocal(DateTime utc) => utc.toUtc();
  @override
  DateTime localComponentsToUtc(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day, date.hour, date.minute);
}

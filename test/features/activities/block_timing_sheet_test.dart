import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_creator.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/activities/presentation/activity_options_sheet.dart';
import 'package:rotina_jhenifer/features/activities/presentation/new_activity_sheet.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_permission_gateway.dart';
import 'package:rotina_jhenifer/main.dart';

final _day = DateTime.utc(2026, 11, 16);

void main() {
  for (final edit in [false, true]) {
    testWidgets(
      '${edit ? 'edição' : 'cadastro'} aceita início13h e final15h com sistema12h e ptBR',
      (tester) async {
        tester.platformDispatcher.alwaysUse24HourFormatTestValue = false;
        addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        ActivityDraft? created;
        ActivityEditDraft? edited;
        if (edit) {
          await tester.pumpWidget(
            DayToDayApp(
              home: Scaffold(
                body: EditActivitySheet(
                  activity: _activity(const Duration(minutes: 47)),
                  occurrence: _occurrence(const Duration(minutes: 47)),
                  timeZone: const _Utc(),
                  clock: const _Clock(),
                  onSave: (draft) async {
                    edited = draft;
                    throw StateError('Keep draft');
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await _tapText(tester, 'Horário de início');
        } else {
          await _newSheet(tester, _Permissions(), (draft) => created = draft);
          await tester.enterText(find.byType(TextFormField).first, 'Estudar');
          await _tapText(tester, 'Reservar tempo na agenda');
          expect(find.text('Início'), findsOneWidget);
          expect(find.text('Quando?'), findsNothing);
          await _tapText(tester, 'Início · 12:30');
        }
        await _chooseTimeInOpenPicker(tester, 13, 0);
        await _endTime(tester, 15, 0);
        await _tapText(
          tester,
          edit ? 'Salvar alterações' : 'Salvar e preparar alarme',
        );
        if (edit) {
          expect(edited?.hour, 13);
          expect(edited?.minute, 0);
          expect(edited?.estimatedDuration, const Duration(hours: 2));
        } else {
          expect(
            (created?.recurrence as OneOffRecurrence).scheduledAtUtc.hour,
            13,
          );
          expect(created?.estimatedDuration, const Duration(hours: 2));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'bloco silencioso preserva opções ao alternar e dispensa acessos',
    (tester) async {
      final permissions = _Permissions();
      ActivityDraft? saved;
      await _newSheet(tester, permissions, (draft) => saved = draft);
      await tester.enterText(find.byType(TextFormField).first, 'Estudar');
      await _tapText(tester, 'Reservar tempo na agenda');
      await _tapKey(tester, 'block-notify-start');
      await _tapText(tester, 'Reservar tempo na agenda');
      expect(find.byKey(const ValueKey('block-notify-start')), findsNothing);
      await _tapText(tester, 'Reservar tempo na agenda');
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('block-notify-start')),
            )
            .value,
        isFalse,
      );
      await _tapText(tester, 'Salvar atividade');
      expect(saved?.kind, ActivityKind.timeBlock);
      expect(saved?.notifyAtStart, isFalse);
      expect(saved?.notifyAtEnd, isFalse);
      expect(saved?.usesBoundaryAlarms, isTrue);
      expect(saved?.estimatedDuration, const Duration(minutes: 30));
      expect(permissions.checks, 0);
      expect(permissions.requests, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'fim anterior bloqueia envio até escolher explicitamente dia seguinte',
    (tester) async {
      ActivityDraft? saved;
      await _newSheet(tester, _Permissions(), (draft) => saved = draft);
      await tester.enterText(find.byType(TextFormField).first, 'Ler');
      await _tapText(tester, 'Reservar tempo na agenda');
      await _endTime(tester, 12, 15);
      expect(tester.takeException(), isNull, reason: 'seletor de horário');
      await _tapText(tester, 'Salvar e preparar alarme');
      expect(saved, isNull);
      expect(
        find.textContaining('Escolha um horário final depois do início.'),
        findsOneWidget,
      );
      await _tapKey(tester, 'block-next-day');
      await _tapKey(tester, 'block-notify-end');
      await _tapText(tester, 'Salvar e preparar alarme');
      expect(saved?.estimatedDuration, const Duration(hours: 23, minutes: 45));
      expect(saved?.notifyAtStart, isTrue);
      expect(saved?.notifyAtEnd, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'lembrete não herda aviso final nem reserva ao sair do modo bloco',
    (tester) async {
      ActivityDraft? saved;
      await _newSheet(tester, _Permissions(), (draft) => saved = draft);
      await tester.enterText(find.byType(TextFormField).first, 'Água');
      await _tapText(tester, 'Reservar tempo na agenda');
      await _tapKey(tester, 'block-notify-start');
      await _tapKey(tester, 'block-notify-end');
      await _tapText(tester, 'Reservar tempo na agenda');
      await _tapText(tester, 'Salvar e preparar alarme');
      expect(saved?.kind, ActivityKind.reminder);
      expect(saved?.estimatedDuration, Duration.zero);
      expect(saved?.notifyAtStart, isTrue);
      expect(saved?.notifyAtEnd, isFalse);
      expect(saved?.usesBoundaryAlarms, isFalse);
    },
  );

  testWidgets(
    'bloco pode avisar somente no final sem completar automaticamente',
    (tester) async {
      final permissions = _Permissions();
      ActivityDraft? saved;
      await _newSheet(tester, permissions, (draft) => saved = draft);
      await tester.enterText(find.byType(TextFormField).first, 'Estudar');
      await _tapText(tester, 'Reservar tempo na agenda');
      await _tapKey(tester, 'block-notify-start');
      await _tapKey(tester, 'block-notify-end');
      await _tapText(tester, 'Salvar e preparar alarme');
      expect(saved?.kind, ActivityKind.timeBlock);
      expect(saved?.notifyAtStart, isFalse);
      expect(saved?.notifyAtEnd, isTrue);
      expect(saved?.usesBoundaryAlarms, isTrue);
      expect(permissions.checks, 1);
      expect(
        find.textContaining('Os avisos não marcam a atividade'),
        findsOneWidget,
      );
    },
  );

  for (final duration in [
    const Duration(minutes: 47),
    const Duration(hours: 50, minutes: 17),
  ]) {
    testWidgets(
      'edição mantém duração legada exata $duration e configura avisos',
      (tester) async {
        ActivityEditDraft? saved;
        final activity = _activity(duration);
        await tester.pumpWidget(
          DayToDayApp(
            home: Scaffold(
              body: EditActivitySheet(
                activity: activity,
                occurrence: _occurrence(duration),
                timeZone: const _Utc(),
                clock: const _Clock(),
                onSave: (draft) async {
                  saved = draft;
                  throw StateError('Keep draft visible');
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _tapKey(tester, 'block-notify-end');
        await _tapText(tester, 'Salvar alterações');
        expect(saved?.estimatedDuration, duration);
        expect(saved?.notifyAtStart, isTrue);
        expect(saved?.notifyAtEnd, isTrue);
        expect(saved?.usesBoundaryAlarms, isTrue);
        expect(
          find.textContaining('Suas alterações continuam aqui'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'horário final e avisos ficam alcançáveis em 320dp 2x com teclado',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _newSheet(tester, _Permissions(), (_) {}, scale: 2, keyboard: 260);
      await _tapText(tester, 'Reservar tempo na agenda');
      await tester.ensureVisible(find.byKey(const ValueKey('block-end-time')));
      await tester.pumpAndSettle();
      expect(find.text('Horário final'), findsOneWidget);
      await _tapKey(tester, 'block-notify-end');
      expect(
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('block-notify-end')),
            )
            .value,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _newSheet(
  WidgetTester tester,
  _Permissions permissions,
  ValueChanged<ActivityDraft> save, {
  double scale = 1,
  double keyboard = 0,
}) async {
  if (scale == 1) {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }
  await tester.pumpWidget(
    DayToDayApp(
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: Scaffold(
          body: NewActivitySheet(
            initialDay: _day,
            timeZone: const _Utc(),
            clock: const _Clock(),
            permissions: permissions,
            onCreate: (draft) async {
              save(draft);
              throw StateError('Keep draft visible');
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

Future<void> _endTime(WidgetTester tester, int hour, int minute) async {
  await _tapKey(tester, 'block-end-time');
  await _chooseTimeInOpenPicker(tester, hour, minute);
}

Future<void> _chooseTimeInOpenPicker(
  WidgetTester tester,
  int hour,
  int minute,
) async {
  expect(tester.takeException(), isNull, reason: 'abrir relógio');
  final pickerContext = tester.element(find.byType(TimePickerDialog));
  expect(Localizations.localeOf(pickerContext), const Locale('pt', 'BR'));
  expect(MediaQuery.alwaysUse24HourFormatOf(pickerContext), isTrue);
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'alternar para digitação');
  final fields = find.descendant(
    of: find.byType(TimePickerDialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), '$hour');
  await tester.enterText(fields.at(1), '$minute');
  await _tapText(tester, 'Escolher');
  expect(find.byType(TimePickerDialog), findsNothing);
}

Activity _activity(Duration duration) => Activity(
  id: 'block',
  title: 'Estudar',
  estimatedDuration: duration,
  priority: ActivityPriority.normal,
  recurrence: OneOffRecurrence(_day.add(const Duration(hours: 15))),
  createdAtUtc: _day,
  updatedAtUtc: _day,
);

ActivityOccurrence _occurrence(Duration duration) => ActivityOccurrence(
  id: 'occ',
  activityId: 'block',
  originalStartUtc: _day.add(const Duration(hours: 15)),
  scheduledStartUtc: _day.add(const Duration(hours: 15)),
  estimatedDuration: duration,
  priority: ActivityPriority.normal,
  status: OccurrenceStatus.scheduled,
);

class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => _day.add(const Duration(hours: 12));
}

class _Utc implements TimeZoneService {
  const _Utc();
  @override
  DateTime toLocal(DateTime utc) => utc.toUtc();
  @override
  DateTime localComponentsToUtc(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, d.hour, d.minute);
}

class _Permissions implements AlarmPermissionGateway {
  int checks = 0, requests = 0;
  @override
  Future<AlarmCapabilities> check() async {
    checks++;
    return const AlarmCapabilities(
      notifications: true,
      exactScheduling: true,
      fullScreen: true,
      doNotDisturbAccess: true,
    );
  }

  @override
  Future<AlarmCapabilities> requestRequiredAccess() async {
    requests++;
    return check();
  }
}

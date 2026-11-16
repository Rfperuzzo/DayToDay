import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/main.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_creator.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_recurrence_preset.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/activities/presentation/new_activity_sheet.dart';
import 'package:rotina_jhenifer/features/activities/presentation/activity_options_sheet.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_permission_gateway.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/today_screen.dart';

void main() {
  final at = DateTime.utc(2026, 11, 14, 10);
  Activity activity({bool reminder = true}) => Activity(
    id: 'a',
    title: 'Beber água',
    kind: reminder ? ActivityKind.reminder : ActivityKind.timeBlock,
    estimatedDuration: const Duration(minutes: 45),
    priority: ActivityPriority.normal,
    recurrence: WeeklyRecurrence(weekdays: {1, 3, 6}, hour: 10, minute: 0),
    createdAtUtc: at,
    updatedAtUtc: at,
  );
  ActivityOccurrence occurrence({
    bool reminder = true,
    bool complete = false,
  }) => ActivityOccurrence(
    id: complete ? 'done' : 'a:1',
    activityId: 'a',
    originalStartUtc: at,
    scheduledStartUtc: at,
    kind: reminder ? ActivityKind.reminder : ActivityKind.timeBlock,
    estimatedDuration: reminder ? Duration.zero : const Duration(minutes: 45),
    priority: ActivityPriority.normal,
    status: complete ? OccurrenceStatus.completed : OccurrenceStatus.scheduled,
  );

  for (final reserve in [false, true]) {
    testWidgets(
      'cadastro ${reserve ? 'com reserva explícita' : 'padrão lembrete sem duração'} salva o modo correto',
      (tester) async {
        ActivityDraft? result;
        await tester.binding.setSurfaceSize(const Size(360, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          DayToDayApp(
            home: Scaffold(
              body: NewActivitySheet(
                initialDay: at,
                timeZone: const _Utc(),
                clock: const _Clock(),
                permissions: _Permissions(),
                onCreate: (draft) async {
                  result = draft;
                  return ActivityCreationResult(
                    activity: activity(reminder: !reserve),
                    generatedOccurrences: 1,
                    alarmsSynchronized: true,
                  );
                },
              ),
            ),
          ),
        );
        await tester.enterText(find.byType(TextFormField).first, 'Beber água');
        expect(
          find.byKey(const ValueKey('block-duration-summary')),
          findsNothing,
        );
        if (reserve) {
          await tester.ensureVisible(find.text('Reservar tempo na agenda'));
          await tester.tap(find.text('Reservar tempo na agenda'));
          await tester.pumpAndSettle();
          expect(find.text('Duração: 30 min'), findsOneWidget);
        }
        await tester.ensureVisible(find.text('Salvar e preparar alarme'));
        await tester.tap(find.text('Salvar e preparar alarme'));
        await tester.pumpAndSettle();
        expect(
          result?.kind,
          reserve ? ActivityKind.timeBlock : ActivityKind.reminder,
        );
        expect(
          result?.estimatedDuration,
          reserve ? const Duration(minutes: 30) : Duration.zero,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('lembrete silenciado oferece lembrar em dez minutos', (
    tester,
  ) async {
    await tester.pumpWidget(
      DayToDayApp(
        home: Scaffold(
          body: ActivityOptionsSheet(
            activity: activity(),
            occurrence: occurrence().copyWith(acknowledgedAtUtc: at),
            timeZone: const _Utc(),
          ),
        ),
      ),
    );
    expect(find.text('Lembrar em 10 minutos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'edição preserva bloco legado e dias personalizados sem alteração',
    (tester) async {
      ActivityEditDraft? result;
      final block = activity(reminder: false);
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        DayToDayApp(
          home: Scaffold(
            body: EditActivitySheet(
              activity: block,
              occurrence: occurrence(reminder: false),
              timeZone: const _Utc(),
              clock: const _Clock(),
              onSave: (draft) async {
                result = draft;
                return ActivityMutationResult(
                  activity: block,
                  affectedOccurrences: 1,
                  generatedOccurrences: 1,
                  alarmsSynchronized: true,
                );
              },
            ),
          ),
        ),
      );
      final toggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Reservar tempo na agenda'),
      );
      expect(toggle.value, isTrue);
      expect(find.text('Duração: 45 min'), findsOneWidget);
      await tester.ensureVisible(find.text('Salvar alterações'));
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(result?.kind, ActivityKind.timeBlock);
      expect(result?.estimatedDuration, const Duration(minutes: 45));
      expect(result?.recurrence, ActivityRecurrencePreset.custom);
      expect(result?.customWeekdays, {1, 3, 6});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dias específicos quebram linha em 320dp 2x e mantêm ao menos um dia',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        DayToDayApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: NewActivitySheet(
                initialDay: at,
                timeZone: const _Utc(),
                clock: const _Clock(),
                permissions: _Permissions(),
                onCreate: (_) async =>
                    throw StateError('Não salvar neste teste'),
              ),
            ),
          ),
        ),
      );
      await tester.ensureVisible(find.text('Dias específicos'));
      await tester.tap(find.text('Dias específicos'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Seg'));
      await tester.tap(find.text('Seg'));
      await tester.pump();
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Seg'))
            .selected,
        isTrue,
      );
      await tester.ensureVisible(find.text('Qua'));
      await tester.tap(find.text('Qua'));
      await tester.pump();
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'Qua'))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'filtro oculta concluídas sem mudar progresso ou perder lembrete pendente',
    (tester) async {
      final reminder = occurrence().copyWith(acknowledgedAtUtc: at);
      await tester.binding.setSurfaceSize(const Size(430, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        DayToDayApp(
          home: TodayDashboard(
            selectedDay: at,
            activities: [activity()],
            occurrences: [reminder, occurrence(complete: true)],
            timeZone: const _Utc(),
            onDaySelected: (_) {},
            onComplete: (_) {},
          ),
        ),
      );
      await tester.ensureVisible(find.text('Só pendentes'));
      await tester.tap(find.text('Só pendentes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('task-done')), findsNothing);
      expect(find.byKey(const ValueKey('task-a:1')), findsOneWidget);
      expect(find.text('Progresso · 1 de 2 concluídas'), findsOneWidget);
      expect(
        find.textContaining('Aviso silenciado · Pendente'),
        findsOneWidget,
      );
      expect(find.textContaining('0 min'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Clock implements Clock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 11, 14, 9);
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
  @override
  Future<AlarmCapabilities> check() async => const AlarmCapabilities(
    notifications: true,
    exactScheduling: true,
    fullScreen: true,
    doNotDisturbAccess: true,
  );
  @override
  Future<AlarmCapabilities> requestRequiredAccess() => check();
}

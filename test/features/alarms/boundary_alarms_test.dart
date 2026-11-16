import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/application/occurrence_generator.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_recurrence_preset.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_event_processor.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/missed_task_recovery_service.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_jhenifer/features/dashboard/application/daily_task_sequence.dart';
import 'package:rotina_jhenifer/features/dashboard/application/occurrence_actions.dart';
import 'package:rotina_jhenifer/features/history/data/drift_activity_event_repository.dart';
import 'package:rotina_jhenifer/features/history/domain/activity_event.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  late _Fixture f;
  setUp(() => f = _Fixture());
  tearDown(() async {
    await f.alarms.controller.close();
    await f.db.close();
  });
  for (final start in [false, true]) {
    for (final end in [false, true]) {
      test(
        'preferências persistem e agendam somente início=$start / fim=$end',
        () async {
          final o = await f.save('Matemática', 8, 10, start: start, end: end);
          final stored = (await f.activities.findById(o.activityId))!;
          expect(stored.notifyAtStart, start);
          expect(stored.notifyAtEnd, end);
          expect(stored.usesBoundaryAlarms, true);
          await f.sync();
          expect(f.alarms.values.length, (start ? 1 : 0) + (end ? 1 : 0));
          if (start) expect(f.alarms.values[o.id]!.scheduledAtUtc, f.at(8));
          if (end) {
            expect(
              f.alarms.values[AlarmIdentity.endKey(o.id)]!.scheduledAtUtc,
              f.at(10),
            );
          }
        },
      );
    }
  }
  test(
    '08–09 e 09–10 produzem somente um aviso de troca às09 e fim às10',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      expect(f.alarms.values, hasLength(3));
      final transition = f.alarms.values[b.id]!;
      expect(transition.phase, AlarmPhase.transition);
      expect(transition.previousOccurrenceId, a.id);
      expect(transition.title, 'Matemática → Português');
      expect(transition.scheduledAtUtc, f.at(9));
      expect(f.alarms.values.containsKey(AlarmIdentity.endKey(a.id)), false);
      final schedules = f.alarms.schedules;
      await f.sync();
      expect(f.alarms.schedules, schedules);
    },
  );
  test('ponta desligada não é ressuscitada por fusão', () async {
    final a = await f.save('Matemática', 8, 9);
    await f.save('Português', 9, 10, start: false);
    await f.sync();
    final at9 = f.alarms.values.values
        .where((r) => r.scheduledAtUtc == f.at(9))
        .single;
    expect(at9.phase, AlarmPhase.end);
    expect(at9.occurrenceId, a.id);
  });
  test('silenciar início preserva fim e estado pendente', () async {
    final a = await f.save('Estudar', 8, 10);
    await f.sync();
    f.clock.value = f.at(8);
    await f.response.respond(
      occurrenceId: a.id,
      response: AlarmResponse.silence,
    );
    expect(f.alarms.values.keys, [AlarmIdentity.endKey(a.id)]);
    final o = (await f.occurrences.findById(a.id))!;
    expect(o.acknowledgedAtUtc, isNotNull);
    expect(o.endAcknowledgedAtUtc, isNull);
    expect(o.status, OccurrenceStatus.scheduled);
  });
  test(
    'silenciar troca confirma as duas pontas mas não conclui e preserva próximo fim',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      f.clock.value = f.at(9);
      await f.response.respond(
        occurrenceId: b.id,
        response: AlarmResponse.silence,
        phase: AlarmPhase.transition,
        previousOccurrenceId: a.id,
      );
      final previous = (await f.occurrences.findById(a.id))!;
      final next = (await f.occurrences.findById(b.id))!;
      expect(previous.endAcknowledgedAtUtc, isNotNull);
      expect(next.acknowledgedAtUtc, isNotNull);
      expect(previous.status, OccurrenceStatus.scheduled);
      expect(next.status, OccurrenceStatus.scheduled);
      expect(next.endAcknowledgedAtUtc, isNull);
      expect(f.alarms.values.keys, [AlarmIdentity.endKey(b.id)]);
      expect(
        (await f.events.findForOccurrence(
          a.id,
        )).where((e) => e.type == ActivityEventType.completed),
        isEmpty,
      );
      expect(
        DailyTaskSequence.isLocked(occurrence: next, available: previous),
        false,
      );
    },
  );
  test('fim encerra aviso sem concluir nem alterar horários', () async {
    final a = await f.save('Estudar', 8, 10);
    await f.sync();
    f.clock.value = f.at(10);
    await f.response.respond(
      occurrenceId: a.id,
      response: AlarmResponse.silence,
      phase: AlarmPhase.end,
    );
    final o = (await f.occurrences.findById(a.id))!;
    expect(o.status, OccurrenceStatus.scheduled);
    expect(o.endAcknowledgedAtUtc, isNotNull);
    expect(o.scheduledStartUtc, a.scheduledStartUtc);
    expect(o.scheduledEndUtc, a.scheduledEndUtc);
    expect(f.alarms.values, isEmpty);
  });
  test(
    'concluir antes do fim remove final e desfaz troca sem cancelar próximo início',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      final actions = OccurrenceActions(
        occurrences: f.occurrences,
        events: f.events,
        alarms: f.alarms,
        alarmReconciler: f.reconciler,
        clock: f.clock,
        preferences: const UserPreferences(),
      );
      await actions.complete(a);
      expect(f.alarms.values.keys.toSet(), {b.id, AlarmIdentity.endKey(b.id)});
      expect(f.alarms.values[b.id]!.phase, AlarmPhase.start);
    },
  );
  test(
    'cancelar próxima atividade restaura fim anterior independente',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      await f.manager.cancel(selectedOccurrence: b);
      expect(
        f.alarms.values[AlarmIdentity.endKey(a.id)]!.phase,
        AlarmPhase.end,
      );
      expect(f.alarms.values.containsKey(b.id), false);
    },
  );
  test(
    'editar horários e preferências remove endpoints antigos e preserva histórico',
    () async {
      final a = await f.save('Estudar', 8, 10);
      await f.sync();
      await f.manager.edit(
        selectedOccurrence: a,
        draft: const ActivityEditDraft(
          title: 'Estudar revisado',
          hour: 8,
          minute: 0,
          recurrence: ActivityRecurrencePreset.once,
          estimatedDuration: Duration(hours: 3),
          notifyAtStart: false,
          notifyAtEnd: true,
          usesBoundaryAlarms: true,
        ),
      );
      expect(f.alarms.values, hasLength(1));
      expect(f.alarms.values.values.single.scheduledAtUtc, f.at(11));
      expect(
        (await f.events.findForOccurrence(a.id)).single.type,
        ActivityEventType.edited,
      );
    },
  );
  test(
    'reinicialização após meia-noite mantém fim pendente do dia anterior sem repetir início',
    () async {
      final a = await f.save('Leitura noturna', 23, 25);
      f.clock.value = f.at(24, 30);
      await f.sync();
      expect(f.alarms.values.keys, [AlarmIdentity.endKey(a.id)]);
      expect(f.alarms.values.values.single.scheduledAtUtc, f.at(25));
      final endId = NativeAlarmId.fromOccurrenceId(AlarmIdentity.endKey(a.id));
      expect((await f.occurrences.findByNativeAlarmId(endId))!.id, a.id);
    },
  );
  test(
    'cancelar durante troca tocando não conclui a anterior nem ressuscita a cancelada',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      f.clock.value = f.at(9, 1);
      await f.manager.cancel(selectedOccurrence: b);
      await f.response.respond(
        occurrenceId: b.id,
        response: AlarmResponse.silence,
        phase: AlarmPhase.transition,
        previousOccurrenceId: a.id,
      );
      expect(
        (await f.occurrences.findById(a.id))!.status,
        OccurrenceStatus.scheduled,
      );
      expect(
        (await f.occurrences.findById(b.id))!.status,
        OccurrenceStatus.cancelled,
      );
      expect(f.alarms.values, isEmpty);
    },
  );
  test(
    'editar durante troca e silenciar evento antigo preserva os novos horários',
    () async {
      final a = await f.save('Matemática', 8, 9);
      final b = await f.save('Português', 9, 10);
      await f.sync();
      f.clock.value = f.at(9, 1);
      await f.manager.edit(
        selectedOccurrence: b,
        draft: const ActivityEditDraft(
          title: 'Português revisado',
          hour: 10,
          minute: 30,
          recurrence: ActivityRecurrencePreset.once,
          estimatedDuration: Duration(minutes: 30),
          notifyAtStart: true,
          notifyAtEnd: true,
          usesBoundaryAlarms: true,
        ),
      );
      await f.response.respond(
        occurrenceId: b.id,
        response: AlarmResponse.silence,
        phase: AlarmPhase.transition,
        previousOccurrenceId: a.id,
      );
      final next = (await f.occurrences.findPendingForActivity(
        b.activityId,
      )).single;
      expect(next.scheduledStartUtc, f.at(10, 30));
      expect(next.scheduledEndUtc, f.at(11));
      expect(next.acknowledgedAtUtc, isNull);
      expect(next.endAcknowledgedAtUtc, isNull);
      expect(f.alarms.values.keys.toSet(), {
        next.id,
        AlarmIdentity.endKey(next.id),
      });
    },
  );
  test(
    'descarte nativo do aviso final não cancela nem reprograma o bloco',
    () async {
      final a = await f.save('Estudar', 8, 10);
      final recovery = MissedTaskRecoveryService(
        occurrences: f.occurrences,
        events: f.events,
        alarms: f.alarms,
        alarmReconciler: f.reconciler,
        planner: const PriorityRoutinePlanner(_Utc()),
        timeZone: const _Utc(),
        clock: f.clock,
        preferences: const UserPreferences(),
      );
      final processor = AlarmEventProcessor(
        occurrences: f.occurrences,
        events: f.events,
        alarms: f.alarms,
        missedTaskRecovery: recovery,
      );
      processor.start();
      try {
        f.alarms.acknowledged = Completer<void>();
        f.alarms.controller.add(
          AlarmPlatformEvent(
            key: 'native-end-drop',
            nativeAlarmId: NativeAlarmId.fromOccurrenceId(
              AlarmIdentity.endKey(a.id),
            ),
            type: AlarmPlatformEventType.dropped,
            cause: AlarmPlatformEventCause.staleAtBoot,
            recordedAtUtc: f.at(11),
            alarmTimeUtc: f.at(10),
          ),
        );
        await f.alarms.acknowledged!.future.timeout(const Duration(seconds: 2));
        final stored = (await f.occurrences.findById(a.id))!;
        expect(stored.status, OccurrenceStatus.scheduled);
        expect(stored.scheduledStartUtc, a.scheduledStartUtc);
        expect(stored.scheduledEndUtc, a.scheduledEndUtc);
        expect(
          (await f.events.findForOccurrence(a.id)).single.type,
          ActivityEventType.alarmDropped,
        );
      } finally {
        await processor.dispose();
      }
    },
  );
  test(
    'reprogramação explícita limpa as duas ciências e conserva preferências',
    () async {
      final a = (await f.save(
        'Estudar',
        8,
        10,
      )).copyWith(acknowledgedAtUtc: f.at(8), endAcknowledgedAtUtc: f.at(10));
      final moved = a.copyWith(scheduledStartUtc: f.at(11));
      expect(moved.acknowledgedAtUtc, isNull);
      expect(moved.endAcknowledgedAtUtc, isNull);
      expect(moved.notifyAtEnd, true);
      expect(moved.usesBoundaryAlarms, true);
    },
  );
}

class _Fixture {
  final db = AppDatabase(NativeDatabase.memory());
  final clock = _Clock();
  final alarms = _Alarms();
  late final activities = DriftActivityRepository(db);
  late final occurrences = DriftOccurrenceRepository(db);
  late final events = DriftActivityEventRepository(db);
  late final reconciler = AlarmReconciler(
    activities: activities,
    occurrences: occurrences,
    alarms: alarms,
    clock: clock,
    timeZone: const _Utc(),
  );
  late final response = AlarmResponseService(
    occurrences: occurrences,
    events: events,
    alarms: alarms,
    planner: const PriorityRoutinePlanner(_Utc()),
    alarmReconciler: reconciler,
    clock: clock,
    preferences: const UserPreferences(),
  );
  late final manager = ActivityManager(
    activities: activities,
    occurrences: occurrences,
    events: events,
    alarms: alarms,
    alarmReconciler: reconciler,
    timeZone: const _Utc(),
    clock: clock,
    preferences: const UserPreferences(),
  );
  DateTime at(int hour, [int minute = 0]) =>
      DateTime.utc(2026, 11, 16, hour, minute);
  Future<void> sync() => reconciler.reconcile(const UserPreferences());
  Future<ActivityOccurrence> save(
    String id,
    int startHour,
    int endHour, {
    bool start = true,
    bool end = true,
  }) async {
    final activity = Activity(
      id: id,
      title: id,
      estimatedDuration: Duration(hours: endHour - startHour),
      priority: ActivityPriority.normal,
      recurrence: OneOffRecurrence(at(startHour)),
      createdAtUtc: at(7),
      updatedAtUtc: at(7),
      usesBoundaryAlarms: true,
      notifyAtStart: start,
      notifyAtEnd: end,
    );
    await activities.save(activity);
    final occurrence = const OccurrenceGenerator(
      _Utc(),
    ).generate(activity: activity, fromUtc: at(0), untilUtc: at(48)).single;
    await occurrences.saveAll([occurrence]);
    return occurrence;
  }
}

class _Clock implements Clock {
  DateTime value = DateTime.utc(2026, 11, 16, 7);
  @override
  DateTime nowUtc() => value;
}

class _Utc implements TimeZoneService {
  const _Utc();
  @override
  DateTime toLocal(DateTime v) => v.toUtc();
  @override
  DateTime localComponentsToUtc(DateTime v) =>
      DateTime.utc(v.year, v.month, v.day, v.hour, v.minute);
}

class _Alarms implements AlarmGateway {
  final controller = StreamController<AlarmPlatformEvent>.broadcast();
  Completer<void>? acknowledged;
  final values = <String, AlarmRequest>{};
  int schedules = 0;
  @override
  Stream<AlarmPlatformEvent> get events => controller.stream;
  @override
  Stream<List<RingingAlarmBinding>> get ringing => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> cancel(String key) async {
    values.remove(key);
  }

  @override
  Future<void> schedule(AlarmRequest r) async {
    values[r.alarmKey] = r;
    schedules++;
  }

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {
    if (acknowledged != null && !acknowledged!.isCompleted) {
      acknowledged!.complete();
    }
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => [
    for (final r in values.values)
      ScheduledAlarmBinding(
        occurrenceId: r.occurrenceId,
        phase: r.phase,
        previousOccurrenceId: r.previousOccurrenceId,
        nativeAlarmId: NativeAlarmId.fromOccurrenceId(r.alarmKey),
        scheduledAtUtc: r.scheduledAtUtc,
        title: r.title,
        body: r.body,
      ),
  ];
}

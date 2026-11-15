import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_creator.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/application/occurrence_generator.dart';
import 'package:rotina_jhenifer/features/activities/application/schedule_availability.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_recurrence_preset.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_event_processor.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_jhenifer/features/dashboard/application/daily_task_sequence.dart';
import 'package:rotina_jhenifer/features/history/data/drift_activity_event_repository.dart';
import 'package:rotina_jhenifer/features/history/domain/activity_event.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/missed_task_recovery_service.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  late _Fixture f;
  setUp(() => f = _Fixture());
  tearDown(() async {
    await f.alarms.controller.close();
    await f.db.close();
  });

  test('lembrete não tem reserva implícita; bloco exige duração positiva', () {
    expect(
      f.activity('water', reminder: true).estimatedDuration,
      Duration.zero,
    );
    expect(
      () => Activity(
        id: 'bad',
        title: 'Bad',
        estimatedDuration: Duration.zero,
        priority: ActivityPriority.normal,
        recurrence: OneOffRecurrence(f.at(10)),
        createdAtUtc: f.at(9),
        updatedAtUtc: f.at(9),
      ),
      throwsArgumentError,
    );
  });

  test(
    'criação de lembrete dentro de bloco não conflita nem altera bloco',
    () async {
      final block = await f.save('study');
      final result = await f.creator.create(
        ActivityDraft(
          title: 'Beber água',
          kind: ActivityKind.reminder,
          estimatedDuration: Duration.zero,
          priority: ActivityPriority.normal,
          recurrence: OneOffRecurrence(f.at(10, 15)),
        ),
      );
      expect(result.activity.isReminder, isTrue);
      expect(result.alarmsSynchronized, isTrue);
      expect(
        (await f.occurrences.findById(block.id))!.scheduledStartUtc,
        f.at(10),
      );
      final reminders = await f.occurrences.findPendingForActivity(
        result.activity.id,
      );
      expect(reminders.single.kind, ActivityKind.reminder);
      expect(reminders.single.scheduledEndUtc, f.at(10, 15));
    },
  );

  test(
    'reserva pode envolver lembrete; duas reservas continuam conflitando',
    () async {
      final water = await f.save('water', reminder: true, minute: 15);
      final block = f.occurrence('study');
      expect(
        () => ScheduleAvailability.ensureAvailable(
          candidates: [block],
          existing: [water],
        ),
        returnsNormally,
      );
      expect(
        () => ScheduleAvailability.ensureAvailable(
          candidates: [water],
          existing: [block],
        ),
        returnsNormally,
      );
      expect(
        () => ScheduleAvailability.ensureAvailable(
          candidates: [block],
          existing: [f.occurrence('other', minute: 15)],
        ),
        throwsA(isA<ScheduleConflictException>()),
      );
    },
  );

  test('lembretes independentes; apenas blocos respeitam sequência', () async {
    final first = f.occurrence('study');
    final second = f.occurrence('walk', hour: 11);
    final water = f.occurrence('water', reminder: true, hour: 9, minute: 30);
    final all = [second, water, first];
    final available = DailyTaskSequence.firstAvailable(all);
    expect(available?.id, first.id);
    expect(
      DailyTaskSequence.isLocked(occurrence: water, available: available),
      isFalse,
    );
    expect(
      DailyTaskSequence.isLocked(occurrence: second, available: available),
      isTrue,
    );
    expect(DailyTaskSequence.nextAction(all)?.id, water.id);
    expect(
      DailyTaskSequence.nextAction([
        water.copyWith(acknowledgedAtUtc: f.at(9)),
        first,
      ])?.id,
      first.id,
    );
  });

  test('reconcilia todos lembretes simultâneos mais primeiro bloco', () async {
    final one = await f.save('water', reminder: true);
    final two = await f.save('medicine', reminder: true);
    final block = await f.save('study');
    await f.save('walk', hour: 11);
    await f.reconciler.reconcile(const UserPreferences());
    expect(f.alarms.values.keys.toSet(), {one.id, two.id, block.id});
    expect(f.alarms.values[one.id]!.estimatedDuration, Duration.zero);
    await f.reconciler.reconcile(const UserPreferences());
    expect(
      f.alarms.schedules,
      3,
      reason: 'horários iguais não geram rearmamento em loop',
    );
  });

  test(
    'reconciliar outro item não cancela aviso vencido que já está registrado',
    () async {
      final water = await f.save('water', reminder: true, hour: 9);
      await f.alarms.schedule(
        AlarmRequest(
          occurrenceId: water.id,
          scheduledAtUtc: f.at(9),
          estimatedDuration: Duration.zero,
          title: 'Água',
          body: '',
        ),
      );
      f.clock.value = f.at(9).add(const Duration(seconds: 5));
      await f.save('study');
      await f.reconciler.reconcile(const UserPreferences());
      expect(f.alarms.values.containsKey(water.id), isTrue);
      final schedules = f.alarms.schedules;
      f.alarms.values.remove(water.id);
      await f.reconciler.reconcile(const UserPreferences());
      expect(
        f.alarms.values.containsKey(water.id),
        isFalse,
        reason: 'aviso passado sem binding não deve ser recriado',
      );
      expect(f.alarms.schedules, schedules);
    },
  );

  test('silenciar salva ack uma vez, mantém pendência e não rearma', () async {
    final water = await f.save('water', reminder: true);
    final block = await f.save('study');
    for (var i = 0; i < 2; i++) {
      final result = await f.response.respond(
        occurrenceId: water.id,
        response: AlarmResponse.silence,
      );
      expect(result.occurrence.status, OccurrenceStatus.scheduled);
      expect(result.occurrence.acknowledgedAtUtc, f.clock.nowUtc());
    }
    expect((await f.events.findForOccurrence(water.id)).map((e) => e.type), [
      ActivityEventType.alarmSilenced,
    ]);
    expect(f.alarms.values.containsKey(water.id), isFalse);
    expect(f.alarms.values.containsKey(block.id), isTrue);
    await f.occurrences.saveGenerated([water]);
    expect(
      (await f.occurrences.findById(water.id))!.acknowledgedAtUtc,
      isNotNull,
    );
  });

  for (final scenario in [
    'lateMove',
    'drop',
    'terminalMove',
    'simultaneousMove',
  ]) {
    test(
      'evento Android $scenario preserva pendência e histórico corretos',
      () async {
        final water = await f.save('water', reminder: true);
        final block = await f.save('study');
        if (scenario == 'lateMove') {
          await f.response.respond(
            occurrenceId: water.id,
            response: AlarmResponse.silence,
          );
        }
        if (scenario == 'terminalMove') {
          await f.response.respond(
            occurrenceId: water.id,
            response: AlarmResponse.complete,
          );
        }
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
        )..start();
        addTearDown(processor.dispose);
        f.alarms.controller.add(
          AlarmPlatformEvent(
            key: scenario,
            nativeAlarmId: NativeAlarmId.fromOccurrenceId(water.id),
            type: scenario == 'drop'
                ? AlarmPlatformEventType.dropped
                : AlarmPlatformEventType.moved,
            cause: AlarmPlatformEventCause.platformRefusal,
            recordedAtUtc: f.at(8, 59),
            alarmTimeUtc: f.at(10, 1),
          ),
        );
        await f.alarms.processed.future;
        final stored = (await f.occurrences.findById(water.id))!;
        expect(stored.originalStartUtc, water.originalStartUtc);
        expect(
          (await f.occurrences.findById(block.id))!.scheduledStartUtc,
          block.scheduledStartUtc,
        );
        expect(
          stored.status,
          scenario == 'terminalMove'
              ? OccurrenceStatus.completed
              : OccurrenceStatus.scheduled,
        );
        expect(
          stored.scheduledStartUtc,
          scenario == 'simultaneousMove'
              ? f.at(10, 1)
              : water.scheduledStartUtc,
        );
        expect(
          stored.acknowledgedAtUtc,
          scenario == 'lateMove' ? f.clock.nowUtc() : null,
        );
      },
    );
  }

  test('concluir após silenciar é independente e idempotente', () async {
    final water = await f.save('water', reminder: true);
    await f.response.respond(
      occurrenceId: water.id,
      response: AlarmResponse.silence,
    );
    for (var i = 0; i < 2; i++) {
      await f.response.respond(
        occurrenceId: water.id,
        response: AlarmResponse.complete,
      );
    }
    final stored = (await f.occurrences.findById(water.id))!;
    expect(stored.status, OccurrenceStatus.completed);
    expect(stored.acknowledgedAtUtc, isNotNull);
    expect(
      (await f.events.findForOccurrence(water.id)).map((e) => e.type).toSet(),
      {ActivityEventType.alarmSilenced, ActivityEventType.completed},
    );
    expect(await f.events.findForOccurrence(water.id), hasLength(2));
  });

  test('silenciar bloco não conclui nem libera o bloco seguinte', () async {
    final first = await f.save('study');
    final second = await f.save('walk', hour: 11);
    await f.response.respond(
      occurrenceId: first.id,
      response: AlarmResponse.silence,
    );
    expect(f.alarms.values.containsKey(second.id), isFalse);
    final stored = (await f.occurrences.findById(first.id))!;
    expect(
      DailyTaskSequence.isLocked(
        occurrence: second,
        available: DailyTaskSequence.firstAvailable([stored, second]),
      ),
      isTrue,
    );
  });

  test(
    'adiar lembrete em dez minutos não desloca blocos e limpa ack',
    () async {
      final water = await f.save('water', reminder: true, hour: 9);
      final block = await f.save('study', hour: 9);
      await f.response.respond(
        occurrenceId: water.id,
        response: AlarmResponse.silence,
      );
      final result = await f.response.respond(
        occurrenceId: water.id,
        response: AlarmResponse.nowNot,
      );
      expect(result.occurrence.scheduledStartUtc, f.at(9, 10));
      expect(result.occurrence.originalStartUtc, water.originalStartUtc);
      expect(result.occurrence.acknowledgedAtUtc, isNull);
      expect(result.adjustedOccurrences, hasLength(1));
      expect(
        (await f.occurrences.findById(block.id))!.scheduledStartUtc,
        f.at(9),
      );
    },
  );

  test(
    'reorganizar bloco ignora lembretes; lembrete perdido não faz cascata',
    () async {
      final block = await f.save('study');
      final water = await f.save('water', reminder: true);
      final plan = const PriorityRoutinePlanner(_Utc()).replanNowNot(
        occurrence: block,
        existingOccurrences: [block, water],
        nowUtc: f.at(10),
        preferences: const UserPreferences(),
      );
      expect(plan.adjustedOccurrences.any((o) => o.id == water.id), isFalse);
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
      expect(await recovery.recover(water.id), isNull);
      expect(
        (await f.occurrences.findById(water.id))!.status,
        OccurrenceStatus.scheduled,
      );
    },
  );

  test(
    'edição preserva seleção de dias específicos e pode converter tipo',
    () async {
      final selected = await f.save('study');
      final manager = ActivityManager(
        activities: f.activities,
        occurrences: f.occurrences,
        events: f.events,
        alarms: f.alarms,
        alarmReconciler: f.reconciler,
        timeZone: const _Utc(),
        clock: f.clock,
        preferences: const UserPreferences(),
      );
      final result = await manager.edit(
        selectedOccurrence: selected,
        draft: const ActivityEditDraft(
          title: 'Estudar',
          hour: 10,
          minute: 0,
          recurrence: ActivityRecurrencePreset.custom,
          customWeekdays: {
            DateTime.monday,
            DateTime.wednesday,
            DateTime.saturday,
          },
          estimatedDuration: Duration.zero,
          kind: ActivityKind.reminder,
        ),
      );
      expect(result.activity.isReminder, isTrue);
      expect((result.activity.recurrence as WeeklyRecurrence).weekdays, {
        1,
        3,
        6,
      });
      final stored = await f.occurrences.findPendingForActivity(
        selected.activityId,
      );
      expect(
        stored.every(
          (o) => o.isReminder && o.estimatedDuration == Duration.zero,
        ),
        isTrue,
      );
    },
  );
  test('editar preserva ocorrência já concluída com mesmo ID futuro', () async {
    final selected = await f.save('study');
    await f.response.respond(
      occurrenceId: selected.id,
      response: AlarmResponse.complete,
    );
    final manager = ActivityManager(
      activities: f.activities,
      occurrences: f.occurrences,
      events: f.events,
      alarms: f.alarms,
      alarmReconciler: f.reconciler,
      timeZone: const _Utc(),
      clock: f.clock,
      preferences: const UserPreferences(),
    );
    await manager.edit(
      selectedOccurrence: selected,
      draft: const ActivityEditDraft(
        title: 'Estudo atualizado',
        hour: 10,
        minute: 0,
        recurrence: ActivityRecurrencePreset.once,
        estimatedDuration: Duration(minutes: 45),
      ),
    );
    final stored = (await f.occurrences.findById(selected.id))!;
    expect(stored.status, OccurrenceStatus.completed);
    expect(stored.estimatedDuration, const Duration(minutes: 30));
    expect(
      (await f.events.findForOccurrence(
        selected.id,
      )).any((e) => e.type == ActivityEventType.completed),
      isTrue,
    );
  });
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
  late final creator = ActivityCreator(
    activities: activities,
    occurrences: occurrences,
    timeZone: const _Utc(),
    alarmReconciler: reconciler,
    clock: clock,
    preferences: const UserPreferences(),
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
  DateTime at(int hour, [int minute = 0]) =>
      DateTime.utc(2026, 11, 14, hour, minute);
  Activity activity(
    String id, {
    bool reminder = false,
    int hour = 10,
    int minute = 0,
  }) => Activity(
    id: id,
    title: id,
    kind: reminder ? ActivityKind.reminder : ActivityKind.timeBlock,
    estimatedDuration: const Duration(minutes: 30),
    priority: ActivityPriority.normal,
    recurrence: OneOffRecurrence(at(hour, minute)),
    createdAtUtc: at(9),
    updatedAtUtc: at(9),
  );
  ActivityOccurrence occurrence(
    String id, {
    bool reminder = false,
    int hour = 10,
    int minute = 0,
  }) => const OccurrenceGenerator(_Utc())
      .generate(
        activity: activity(id, reminder: reminder, hour: hour, minute: minute),
        fromUtc: at(0),
        untilUtc: at(23),
      )
      .single;
  Future<ActivityOccurrence> save(
    String id, {
    bool reminder = false,
    int hour = 10,
    int minute = 0,
  }) async {
    await activities.save(
      activity(id, reminder: reminder, hour: hour, minute: minute),
    );
    final o = occurrence(id, reminder: reminder, hour: hour, minute: minute);
    await occurrences.saveAll([o]);
    return o;
  }
}

class _Clock implements Clock {
  DateTime value = DateTime.utc(2026, 11, 14, 9);
  @override
  DateTime nowUtc() => value;
}

class _Utc implements TimeZoneService {
  const _Utc();
  @override
  DateTime toLocal(DateTime utc) => utc.toUtc();
  @override
  DateTime localComponentsToUtc(DateTime local) => DateTime.utc(
    local.year,
    local.month,
    local.day,
    local.hour,
    local.minute,
  );
}

class _Alarms implements AlarmGateway {
  final controller = StreamController<AlarmPlatformEvent>.broadcast();
  final processed = Completer<AlarmPlatformEvent>();
  final values = <String, AlarmRequest>{};
  int schedules = 0;
  @override
  Stream<AlarmPlatformEvent> get events => controller.stream;
  @override
  Stream<List<RingingAlarmBinding>> get ringing => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> cancel(String id) async {
    values.remove(id);
  }

  @override
  Future<void> schedule(AlarmRequest request) async {
    values[request.occurrenceId] = request;
    schedules++;
  }

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {
    if (!processed.isCompleted) processed.complete(event);
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => values.values
      .map(
        (r) => ScheduledAlarmBinding(
          occurrenceId: r.occurrenceId,
          nativeAlarmId: NativeAlarmId.fromOccurrenceId(r.occurrenceId),
          scheduledAtUtc: r.scheduledAtUtc,
        ),
      )
      .toList();
}

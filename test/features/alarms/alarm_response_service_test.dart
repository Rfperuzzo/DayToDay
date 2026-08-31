import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/core/time/clock.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_andriele/features/activities/domain/activity_repositories.dart';
import 'package:rotina_andriele/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_andriele/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_andriele/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_andriele/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_andriele/features/history/domain/activity_event.dart';
import 'package:rotina_andriele/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_andriele/features/settings/domain/user_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 8, 31, 10, 2);

  test('concluir encerra alarme, ocorrência e histórico', () async {
    final fixture = _Fixture(now);

    final result = await fixture.service.respond(
      occurrenceId: fixture.target.id,
      response: AlarmResponse.complete,
    );

    expect(result.occurrence.status, OccurrenceStatus.completed);
    expect(fixture.alarms.cancelled, [fixture.target.id]);
    expect(fixture.events.values.single.type, ActivityEventType.completed);
  });

  test('pular hoje não altera a recorrência original', () async {
    final fixture = _Fixture(now);
    final originalStart = fixture.target.originalStartUtc;

    final result = await fixture.service.respond(
      occurrenceId: fixture.target.id,
      response: AlarmResponse.skipToday,
    );

    expect(result.occurrence.status, OccurrenceStatus.skipped);
    expect(result.occurrence.originalStartUtc, originalStart);
    expect(fixture.events.values.single.type, ActivityEventType.skipped);
  });

  test('agora não resgata a rotina e explica o novo horário', () async {
    final conflict = _occurrence(
      'prioridade',
      DateTime.utc(2026, 8, 31, 10, 5),
      durationMinutes: 60,
      priority: ActivityPriority.high,
    );
    final fixture = _Fixture(now, extra: [conflict]);

    final result = await fixture.service.respond(
      occurrenceId: fixture.target.id,
      response: AlarmResponse.nowNot,
    );

    expect(
      result.occurrence.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 5),
    );
    expect(result.occurrence.attempt, 1);
    expect(result.alarmsSynchronized, isTrue);
    expect(
      fixture.events.values.any(
        (item) => item.type == ActivityEventType.nowNot,
      ),
      isTrue,
    );
    expect(
      fixture.alarms.requests.any((item) => item.occurrenceId == conflict.id),
      isTrue,
    );
    expect(
      fixture.alarms.requests.any(
        (item) => item.occurrenceId == fixture.target.id,
      ),
      isFalse,
    );
  });
}

final class _Fixture {
  _Fixture(DateTime now, {List<ActivityOccurrence> extra = const []})
    : target = _occurrence(
        'alvo',
        DateTime.utc(2026, 8, 31, 10),
        durationMinutes: 30,
        priority: ActivityPriority.normal,
      ),
      clock = _FixedClock(now) {
    occurrences.values.addAll([target, ...extra]);
    activities.values.addAll({
      for (final occurrence in occurrences.values)
        occurrence.activityId: _activityFor(occurrence),
    });
    final reconciler = AlarmReconciler(
      activities: activities,
      occurrences: occurrences,
      alarms: alarms,
      clock: clock,
      timeZone: const _UtcTimeZone(),
    );
    service = AlarmResponseService(
      occurrences: occurrences,
      events: events,
      alarms: alarms,
      planner: const PriorityRoutinePlanner(_UtcTimeZone()),
      alarmReconciler: reconciler,
      clock: clock,
      preferences: const UserPreferences(),
    );
  }

  final ActivityOccurrence target;
  final _FixedClock clock;
  final activities = _MemoryActivities();
  final occurrences = _MemoryOccurrences();
  final events = _MemoryEvents();
  final alarms = _MemoryAlarms();
  late final AlarmResponseService service;
}

ActivityOccurrence _occurrence(
  String id,
  DateTime start, {
  required int durationMinutes,
  required ActivityPriority priority,
}) => ActivityOccurrence(
  id: id,
  activityId: 'activity-$id',
  originalStartUtc: start,
  scheduledStartUtc: start,
  estimatedDuration: Duration(minutes: durationMinutes),
  priority: priority,
  status: OccurrenceStatus.scheduled,
);

Activity _activityFor(ActivityOccurrence occurrence) => Activity(
  id: occurrence.activityId,
  title: 'Atividade ${occurrence.id}',
  estimatedDuration: occurrence.estimatedDuration,
  priority: occurrence.priority,
  recurrence: OneOffRecurrence(occurrence.originalStartUtc),
  createdAtUtc: DateTime.utc(2026, 8, 1),
  updatedAtUtc: DateTime.utc(2026, 8, 1),
);

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
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
  DateTime toLocal(DateTime utc) => utc.toUtc();
}

final class _MemoryActivities implements ActivityRepository {
  final values = <String, Activity>{};

  @override
  Future<Activity?> findById(String id) async => values[id];

  @override
  Future<void> save(Activity activity) async => values[activity.id] = activity;

  @override
  Stream<List<Activity>> watchActive() => Stream.value(values.values.toList());

  @override
  Stream<List<Activity>> watchAll() => watchActive();
}

final class _MemoryOccurrences implements OccurrenceRepository {
  final values = <ActivityOccurrence>[];

  @override
  Future<ActivityOccurrence?> findById(String id) async =>
      values.where((item) => item.id == id).firstOrNull;

  @override
  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId) async =>
      null;

  @override
  Future<List<ActivityOccurrence>> findScheduledBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) async => values
      .where(
        (item) =>
            item.status == OccurrenceStatus.scheduled &&
            !item.scheduledStartUtc.isBefore(startUtc) &&
            item.scheduledStartUtc.isBefore(endUtc),
      )
      .toList();

  @override
  Future<List<ActivityOccurrence>> findPendingForActivity(
    String activityId,
  ) async => values
      .where(
        (item) =>
            item.activityId == activityId &&
            (item.status == OccurrenceStatus.scheduled ||
                item.status == OccurrenceStatus.ringing ||
                item.status == OccurrenceStatus.postponed),
      )
      .toList();

  @override
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences) async {
    for (final occurrence in occurrences) {
      await update(occurrence);
    }
  }

  @override
  Future<int> saveGenerated(Iterable<ActivityOccurrence> occurrences) async {
    var saved = 0;
    for (final occurrence in occurrences) {
      final existing = await findById(occurrence.id);
      if (existing == null || existing.status == OccurrenceStatus.cancelled) {
        await update(occurrence);
        saved++;
      }
    }
    return saved;
  }

  @override
  Future<void> update(ActivityOccurrence occurrence) async {
    values
      ..removeWhere((item) => item.id == occurrence.id)
      ..add(occurrence);
  }

  @override
  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) => Stream.value(values);
}

final class _MemoryEvents implements ActivityEventRepository {
  final values = <ActivityEvent>[];

  @override
  Future<void> append(ActivityEvent event) async => values.add(event);

  @override
  Future<List<ActivityEvent>> findForOccurrence(String occurrenceId) async =>
      values.where((item) => item.occurrenceId == occurrenceId).toList();
}

final class _MemoryAlarms implements AlarmGateway {
  final cancelled = <String>[];
  final requests = <AlarmRequest>[];

  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();

  @override
  Stream<List<RingingAlarmBinding>> get ringing => const Stream.empty();

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}

  @override
  Future<void> cancel(String occurrenceId) async => cancelled.add(occurrenceId);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(AlarmRequest request) async => requests.add(request);

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => const [];
}

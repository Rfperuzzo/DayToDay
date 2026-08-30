import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/history/domain/activity_event.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/missed_task_recovery_service.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  test('persiste a cascata e prepara o alarme da tarefa recuperada', () async {
    final now = DateTime.utc(2026, 8, 31, 10, 30);
    final missed = _occurrence(
      'perdida',
      DateTime.utc(2026, 8, 31, 10),
      durationMinutes: 30,
      priority: ActivityPriority.high,
    );
    final normal = _occurrence(
      'normal',
      DateTime.utc(2026, 8, 31, 11),
      durationMinutes: 30,
      priority: ActivityPriority.normal,
    );
    final flexible = _occurrence(
      'flexivel',
      DateTime.utc(2026, 8, 31, 11, 30),
      durationMinutes: 20,
      priority: ActivityPriority.low,
    );
    final occurrences = _MemoryOccurrences([missed, normal, flexible]);
    final activities = _MemoryActivities([
      _activityFor(missed),
      _activityFor(normal),
      _activityFor(flexible),
    ]);
    final events = _MemoryEvents();
    final alarms = _MemoryAlarms();
    final clock = _FixedClock(now);
    final reconciler = AlarmReconciler(
      activities: activities,
      occurrences: occurrences,
      alarms: alarms,
      clock: clock,
      timeZone: const _UtcTimeZone(),
    );
    final service = MissedTaskRecoveryService(
      occurrences: occurrences,
      events: events,
      alarms: alarms,
      alarmReconciler: reconciler,
      planner: const PriorityRoutinePlanner(_UtcTimeZone()),
      timeZone: const _UtcTimeZone(),
      clock: clock,
      preferences: const UserPreferences(),
    );

    final result = await service.recover(missed.id);

    expect(result, isNotNull);
    expect(result!.recovered.scheduledStartUtc, DateTime.utc(2026, 8, 31, 11));
    expect(
      occurrences.values
          .singleWhere((item) => item.id == normal.id)
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 30),
    );
    expect(
      occurrences.values
          .singleWhere((item) => item.id == flexible.id)
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 12, 10),
    );
    expect(events.values.first.type, ActivityEventType.missed);
    expect(
      events.values
          .where(
            (item) => item.type == ActivityEventType.automaticallyRescheduled,
          )
          .length,
      2,
    );
    expect(alarms.cancelled, contains(missed.id));
    expect(alarms.requests.single.occurrenceId, missed.id);
  });
}

ActivityOccurrence _occurrence(
  String id,
  DateTime start, {
  required int durationMinutes,
  required ActivityPriority priority,
}) => ActivityOccurrence(
  id: id,
  activityId: 'atividade-$id',
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
  _MemoryActivities(Iterable<Activity> items)
    : values = {for (final item in items) item.id: item};

  final Map<String, Activity> values;

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
  _MemoryOccurrences(Iterable<ActivityOccurrence> items)
    : values = items.toList();

  final List<ActivityOccurrence> values;

  @override
  Future<ActivityOccurrence?> findById(String id) async =>
      values.where((item) => item.id == id).firstOrNull;

  @override
  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId) async =>
      null;

  @override
  Future<List<ActivityOccurrence>> findPendingForActivity(
    String activityId,
  ) async => values.where((item) => item.activityId == activityId).toList();

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

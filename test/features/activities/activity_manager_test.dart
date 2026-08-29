import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_manager.dart';
import 'package:rotina_jhenifer/features/activities/application/schedule_availability.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_recurrence_preset.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_jhenifer/features/history/domain/activity_event.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  test(
    'edita nome e horário das próximas repetições e refaz alarmes',
    () async {
      final fixture = _Fixture();

      final result = await fixture.manager.edit(
        selectedOccurrence: fixture.today,
        draft: const ActivityEditDraft(
          title: 'Treino de força',
          hour: 18,
          minute: 30,
          recurrence: ActivityRecurrencePreset.daily,
          estimatedDuration: Duration(minutes: 60),
        ),
      );

      final saved = fixture.activities.value!;
      final recurrence = saved.recurrence as WeeklyRecurrence;
      expect(saved.title, 'Treino de força');
      expect(recurrence.hour, 18);
      expect(recurrence.minute, 30);
      expect(result.affectedOccurrences, 2);
      expect(result.generatedOccurrences, greaterThan(2));
      expect(result.alarmsSynchronized, isTrue);
      expect(
        fixture.occurrences.values
            .where((item) => item.status == OccurrenceStatus.scheduled)
            .every((item) => item.scheduledStartUtc.hour == 18),
        isTrue,
      );
      expect(
        fixture.alarms.cancelled,
        containsAll(['treino:hoje', 'treino:amanha']),
      );
      expect(fixture.alarms.requests, isNotEmpty);
      expect(fixture.alarms.requests.first.title, 'Treino de força');
      expect(fixture.events.values.single.type, ActivityEventType.edited);
    },
  );

  test('transforma repetição diária em tarefa somente para o dia', () async {
    final fixture = _Fixture();

    final result = await fixture.manager.edit(
      selectedOccurrence: fixture.today,
      draft: const ActivityEditDraft(
        title: 'Treino especial',
        hour: 16,
        minute: 0,
        recurrence: ActivityRecurrencePreset.once,
        estimatedDuration: Duration(minutes: 60),
      ),
    );

    final recurrence = fixture.activities.value!.recurrence;
    expect(recurrence, isA<OneOffRecurrence>());
    expect(
      (recurrence as OneOffRecurrence).scheduledAtUtc,
      DateTime.utc(2026, 8, 29, 16),
    );
    final scheduled = fixture.occurrences.values
        .where((item) => item.status == OccurrenceStatus.scheduled)
        .toList();
    expect(scheduled, hasLength(1));
    expect(result.generatedOccurrences, 1);
  });

  test('não aumenta duração quando ela invade outra tarefa', () async {
    final fixture = _Fixture();
    fixture.occurrences.values.add(
      ActivityOccurrence(
        id: 'consulta:hoje',
        activityId: 'consulta',
        originalStartUtc: DateTime.utc(2026, 8, 29, 15, 45),
        scheduledStartUtc: DateTime.utc(2026, 8, 29, 15, 45),
        estimatedDuration: const Duration(minutes: 30),
        priority: ActivityPriority.normal,
        status: OccurrenceStatus.scheduled,
      ),
    );

    final edit = fixture.manager.edit(
      selectedOccurrence: fixture.today,
      draft: const ActivityEditDraft(
        title: 'Treino longo',
        hour: 15,
        minute: 0,
        recurrence: ActivityRecurrencePreset.daily,
        estimatedDuration: Duration(minutes: 90),
      ),
    );

    await expectLater(edit, throwsA(isA<ScheduleConflictException>()));
    expect(
      fixture.activities.value!.estimatedDuration,
      const Duration(minutes: 60),
    );
    expect(fixture.events.values, isEmpty);
  });

  test(
    'cancelamento desativa atividade e remove todos os alarmes futuros',
    () async {
      final fixture = _Fixture();

      final result = await fixture.manager.cancel(
        selectedOccurrence: fixture.today,
      );

      expect(fixture.activities.value!.isActive, isFalse);
      expect(result.affectedOccurrences, 2);
      expect(result.generatedOccurrences, 0);
      expect(result.alarmsSynchronized, isTrue);
      expect(
        fixture.occurrences.values.every(
          (item) => item.status == OccurrenceStatus.cancelled,
        ),
        isTrue,
      );
      expect(
        fixture.alarms.cancelled,
        containsAll(['treino:hoje', 'treino:amanha']),
      );
      expect(fixture.alarms.requests, isEmpty);
      expect(fixture.events.values.single.type, ActivityEventType.cancelled);
    },
  );
}

final class _Fixture {
  _Fixture() {
    activities.value = activity;
    occurrences.values.addAll([today, tomorrow]);
    alarms.bindings.addAll([_binding(today), _binding(tomorrow)]);
    final reconciler = AlarmReconciler(
      activities: activities,
      occurrences: occurrences,
      alarms: alarms,
      clock: clock,
      timeZone: const _UtcTimeZone(),
    );
    manager = ActivityManager(
      activities: activities,
      occurrences: occurrences,
      events: events,
      alarms: alarms,
      alarmReconciler: reconciler,
      timeZone: const _UtcTimeZone(),
      clock: clock,
      preferences: preferences,
    );
  }

  static final now = DateTime.utc(2026, 8, 29, 12);
  static const preferences = UserPreferences(scheduleHorizonDays: 30);
  final clock = _FixedClock(now);
  final activities = _MemoryActivities();
  final occurrences = _MemoryOccurrences();
  final events = _MemoryEvents();
  final alarms = _MemoryAlarms();
  late final ActivityManager manager;

  final activity = Activity(
    id: 'treino',
    title: 'Treino',
    estimatedDuration: const Duration(minutes: 60),
    priority: ActivityPriority.high,
    recurrence: WeeklyRecurrence.daily(hour: 15, minute: 0),
    createdAtUtc: now.subtract(const Duration(days: 10)),
    updatedAtUtc: now.subtract(const Duration(days: 10)),
  );

  final today = ActivityOccurrence(
    id: 'treino:hoje',
    activityId: 'treino',
    originalStartUtc: DateTime.utc(2026, 8, 29, 15),
    scheduledStartUtc: DateTime.utc(2026, 8, 29, 15),
    estimatedDuration: const Duration(minutes: 60),
    priority: ActivityPriority.high,
    status: OccurrenceStatus.scheduled,
  );

  final tomorrow = ActivityOccurrence(
    id: 'treino:amanha',
    activityId: 'treino',
    originalStartUtc: DateTime.utc(2026, 8, 30, 15),
    scheduledStartUtc: DateTime.utc(2026, 8, 30, 15),
    estimatedDuration: const Duration(minutes: 60),
    priority: ActivityPriority.high,
    status: OccurrenceStatus.scheduled,
  );

  ScheduledAlarmBinding _binding(ActivityOccurrence occurrence) =>
      ScheduledAlarmBinding(
        occurrenceId: occurrence.id,
        nativeAlarmId: NativeAlarmId.fromOccurrenceId(occurrence.id),
        scheduledAtUtc: occurrence.scheduledStartUtc,
      );
}

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

final class _MemoryActivities implements ActivityRepository {
  Activity? value;

  @override
  Future<Activity?> findById(String id) async => value?.id == id ? value : null;

  @override
  Future<void> save(Activity activity) async => value = activity;

  @override
  Stream<List<Activity>> watchActive() =>
      Stream.value([if (value?.isActive == true) value!]);

  @override
  Stream<List<Activity>> watchAll() => Stream.value([?value]);
}

final class _MemoryOccurrences implements OccurrenceRepository {
  final values = <ActivityOccurrence>[];

  @override
  Future<ActivityOccurrence?> findById(String id) async =>
      values.where((item) => item.id == id).firstOrNull;

  @override
  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId) async =>
      values
          .where(
            (item) => NativeAlarmId.fromOccurrenceId(item.id) == nativeAlarmId,
          )
          .firstOrNull;

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
  final bindings = <ScheduledAlarmBinding>[];
  final cancelled = <String>[];
  final requests = <AlarmRequest>[];

  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();

  @override
  Stream<List<RingingAlarmBinding>> get ringing => const Stream.empty();

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}

  @override
  Future<void> cancel(String occurrenceId) async {
    cancelled.add(occurrenceId);
    bindings.removeWhere((item) => item.occurrenceId == occurrenceId);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(AlarmRequest request) async {
    requests.add(request);
    bindings
      ..removeWhere((item) => item.occurrenceId == request.occurrenceId)
      ..add(
        ScheduledAlarmBinding(
          occurrenceId: request.occurrenceId,
          nativeAlarmId: NativeAlarmId.fromOccurrenceId(request.occurrenceId),
          scheduledAtUtc: request.scheduledAtUtc,
        ),
      );
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => [...bindings];
}

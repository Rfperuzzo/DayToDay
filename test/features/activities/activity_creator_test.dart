import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/activity_creator.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  test('salva atividade, gera ocorrência e sincroniza o alarme', () async {
    final now = DateTime.utc(2026, 8, 29, 12);
    final activities = _MemoryActivities();
    final occurrences = _MemoryOccurrences();
    final alarms = _MemoryAlarms();
    final clock = _FixedClock(now);
    final creator = ActivityCreator(
      activities: activities,
      occurrences: occurrences,
      timeZone: const _UtcTimeZone(),
      alarmReconciler: AlarmReconciler(
        activities: activities,
        occurrences: occurrences,
        alarms: alarms,
        clock: clock,
      ),
      clock: clock,
      preferences: const UserPreferences(),
    );

    final result = await creator.create(
      ActivityDraft(
        title: 'Treino de pernas',
        notes: 'Academia',
        estimatedDuration: const Duration(minutes: 60),
        priority: ActivityPriority.high,
        recurrence: OneOffRecurrence(DateTime.utc(2026, 8, 29, 13)),
      ),
    );

    expect(result.generatedOccurrences, 1);
    expect(result.alarmsSynchronized, isTrue);
    expect(activities.value?.title, 'Treino de pernas');
    expect(occurrences.values, hasLength(1));
    expect(alarms.requests.single.title, 'Treino de pernas');
  });
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
  DateTime toLocal(DateTime utc) => utc.toUtc();
}

final class _MemoryActivities implements ActivityRepository {
  Activity? value;

  @override
  Future<Activity?> findById(String id) async => value?.id == id ? value : null;

  @override
  Future<void> save(Activity activity) async => value = activity;

  @override
  Stream<List<Activity>> watchActive() => Stream.value([?value]);
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
    values.addAll(occurrences);
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

final class _MemoryAlarms implements AlarmGateway {
  final requests = <AlarmRequest>[];

  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}

  @override
  Future<void> cancel(String occurrenceId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(AlarmRequest request) async => requests.add(request);

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => const [];
}

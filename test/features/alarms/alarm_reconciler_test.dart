import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/core/time/clock.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_andriele/features/activities/domain/activity_repositories.dart';
import 'package:rotina_andriele/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_andriele/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_andriele/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_andriele/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_andriele/features/settings/domain/user_preferences.dart';

void main() {
  test('agenda o desejado e cancela alarme sem ocorrência', () async {
    final activity = Activity(
      id: 'atividade-1',
      title: 'Tomar água',
      estimatedDuration: const Duration(minutes: 10),
      priority: ActivityPriority.normal,
      recurrence: OneOffRecurrence(DateTime.utc(2026, 8, 30, 11)),
      createdAtUtc: DateTime.utc(2026, 8, 29),
      updatedAtUtc: DateTime.utc(2026, 8, 29),
    );
    final occurrence = ActivityOccurrence(
      id: 'ocorrencia-1',
      activityId: activity.id,
      originalStartUtc: DateTime.utc(2026, 8, 30, 11),
      scheduledStartUtc: DateTime.utc(2026, 8, 30, 11),
      estimatedDuration: const Duration(minutes: 10),
      priority: ActivityPriority.normal,
      status: OccurrenceStatus.scheduled,
    );
    final alarms = _FakeAlarmGateway([
      ScheduledAlarmBinding(
        occurrenceId: 'obsoleto',
        nativeAlarmId: NativeAlarmId.fromOccurrenceId('obsoleto'),
        scheduledAtUtc: DateTime.utc(2026, 8, 30, 8),
      ),
    ]);
    final reconciler = AlarmReconciler(
      activities: _FakeActivityRepository(activity),
      occurrences: _FakeOccurrenceRepository([occurrence]),
      alarms: alarms,
      clock: _FixedClock(DateTime.utc(2026, 8, 29, 10)),
      timeZone: const _UtcTimeZone(),
    );

    await reconciler.reconcile(const UserPreferences());

    expect(alarms.cancelled, ['obsoleto']);
    expect(alarms.requests.single.occurrenceId, occurrence.id);
    expect(alarms.requests.single.title, 'Tomar água');
  });

  test('identificador nativo é estável, positivo e não nulo', () {
    final first = NativeAlarmId.fromOccurrenceId('atividade:123');

    expect(first, NativeAlarmId.fromOccurrenceId('atividade:123'));
    expect(first, greaterThan(0));
    expect(first, lessThanOrEqualTo(0x7fffffff));
    expect(first, isNot(NativeAlarmId.fromOccurrenceId('atividade:124')));
  });

  test('agenda somente a primeira tarefa pendente de cada dia', () async {
    final activity = Activity(
      id: 'rotina',
      title: 'Rotina sequencial',
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      recurrence: OneOffRecurrence(DateTime.utc(2026, 8, 30, 9)),
      createdAtUtc: DateTime.utc(2026, 8, 29),
      updatedAtUtc: DateTime.utc(2026, 8, 29),
    );
    final first = ActivityOccurrence(
      id: 'primeira',
      activityId: activity.id,
      originalStartUtc: DateTime.utc(2026, 8, 30, 9),
      scheduledStartUtc: DateTime.utc(2026, 8, 30, 9),
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      status: OccurrenceStatus.scheduled,
    );
    final second = ActivityOccurrence(
      id: 'segunda',
      activityId: activity.id,
      originalStartUtc: DateTime.utc(2026, 8, 30, 10),
      scheduledStartUtc: DateTime.utc(2026, 8, 30, 10),
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      status: OccurrenceStatus.scheduled,
    );
    final alarms = _FakeAlarmGateway([]);
    final reconciler = AlarmReconciler(
      activities: _FakeActivityRepository(activity),
      occurrences: _FakeOccurrenceRepository([second, first]),
      alarms: alarms,
      clock: _FixedClock(DateTime.utc(2026, 8, 29, 10)),
      timeZone: const _UtcTimeZone(),
    );

    await reconciler.reconcile(const UserPreferences());

    expect(alarms.requests, hasLength(1));
    expect(alarms.requests.single.occurrenceId, first.id);
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

final class _FakeActivityRepository implements ActivityRepository {
  _FakeActivityRepository(this.activity);

  final Activity activity;

  @override
  Future<Activity?> findById(String id) async =>
      id == activity.id ? activity : null;

  @override
  Future<void> save(Activity activity) async {}

  @override
  Stream<List<Activity>> watchActive() => Stream.value([activity]);

  @override
  Stream<List<Activity>> watchAll() => watchActive();
}

final class _FakeOccurrenceRepository implements OccurrenceRepository {
  _FakeOccurrenceRepository(this.values);

  final List<ActivityOccurrence> values;

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
  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) => Stream.value(
    values
        .where(
          (item) =>
              !item.scheduledStartUtc.isBefore(startUtc) &&
              item.scheduledStartUtc.isBefore(endUtc),
        )
        .toList(),
  );

  @override
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences) async {}

  @override
  Future<int> saveGenerated(Iterable<ActivityOccurrence> occurrences) async =>
      0;

  @override
  Future<void> update(ActivityOccurrence occurrence) async {}
}

final class _FakeAlarmGateway implements AlarmGateway {
  _FakeAlarmGateway(this.bindings);

  final List<ScheduledAlarmBinding> bindings;
  final List<AlarmRequest> requests = [];
  final List<String> cancelled = [];

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
  Future<List<ScheduledAlarmBinding>> scheduled() async => List.of(bindings);
}

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/activity.dart' as domain;
import '../domain/activity_occurrence.dart';
import '../domain/activity_repositories.dart';
import '../domain/recurrence_rule.dart';
import '../../alarms/infrastructure/native_alarm_id.dart';

final class DriftActivityRepository implements ActivityRepository {
  const DriftActivityRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(domain.Activity activity) async {
    await _database
        .into(_database.activities)
        .insertOnConflictUpdate(_activityCompanion(activity));
  }

  @override
  Future<domain.Activity?> findById(String id) async {
    final query = _database.select(_database.activities)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _activityFromRow(row);
  }

  @override
  Stream<List<domain.Activity>> watchActive() {
    final query = _database.select(_database.activities)
      ..where((table) => table.isActive.equals(true))
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);
    return query.watch().map(
      (rows) => rows.map(_activityFromRow).toList(growable: false),
    );
  }
}

final class DriftOccurrenceRepository implements OccurrenceRepository {
  const DriftOccurrenceRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.occurrences,
        occurrences.map(_occurrenceCompanion),
      );
    });
  }

  @override
  Future<void> update(ActivityOccurrence occurrence) async {
    await _database
        .into(_database.occurrences)
        .insertOnConflictUpdate(_occurrenceCompanion(occurrence));
  }

  @override
  Future<ActivityOccurrence?> findById(String id) async {
    final query = _database.select(_database.occurrences)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _occurrenceFromRow(row);
  }

  @override
  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId) async {
    final query = _database.select(_database.occurrences)
      ..where((table) => table.nativeAlarmId.equals(nativeAlarmId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _occurrenceFromRow(row);
  }

  @override
  Future<List<ActivityOccurrence>> findScheduledBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) async {
    final query = _database.select(_database.occurrences)
      ..where(
        (table) =>
            table.scheduledStartUtc.isBiggerOrEqualValue(startUtc.toUtc()) &
            table.scheduledStartUtc.isSmallerThanValue(endUtc.toUtc()) &
            table.status.equals(OccurrenceStatus.scheduled.name),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.scheduledStartUtc)]);
    final rows = await query.get();
    return rows.map(_occurrenceFromRow).toList(growable: false);
  }

  @override
  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) {
    final query = _database.select(_database.occurrences)
      ..where(
        (table) =>
            table.scheduledStartUtc.isBiggerOrEqualValue(startUtc.toUtc()) &
            table.scheduledStartUtc.isSmallerThanValue(endUtc.toUtc()),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.scheduledStartUtc)]);
    return query.watch().map(
      (rows) => rows
          .map(_occurrenceFromRow)
          .where((item) => item.status != OccurrenceStatus.cancelled)
          .toList(growable: false),
    );
  }
}

ActivitiesCompanion _activityCompanion(domain.Activity activity) {
  final recurrence = activity.recurrence;
  return ActivitiesCompanion(
    id: Value(activity.id),
    title: Value(activity.title),
    notes: Value(activity.notes),
    durationMinutes: Value(activity.estimatedDuration.inMinutes),
    priority: Value(activity.priority.name),
    recurrenceType: Value(recurrence is OneOffRecurrence ? 'oneOff' : 'weekly'),
    oneOffAtUtc: Value(
      recurrence is OneOffRecurrence ? recurrence.scheduledAtUtc : null,
    ),
    weekdaysMask: Value(
      recurrence is WeeklyRecurrence
          ? _encodeWeekdays(recurrence.weekdays)
          : null,
    ),
    localHour: Value(recurrence is WeeklyRecurrence ? recurrence.hour : null),
    localMinute: Value(
      recurrence is WeeklyRecurrence ? recurrence.minute : null,
    ),
    preparationLeadMinutes: Value(activity.preparationLead?.inMinutes),
    isActive: Value(activity.isActive),
    createdAtUtc: Value(activity.createdAtUtc),
    updatedAtUtc: Value(activity.updatedAtUtc),
  );
}

domain.Activity _activityFromRow(ActivityRow row) {
  final recurrence = switch (row.recurrenceType) {
    'oneOff' => OneOffRecurrence(row.oneOffAtUtc!),
    'weekly' => WeeklyRecurrence(
      weekdays: _decodeWeekdays(row.weekdaysMask!),
      hour: row.localHour!,
      minute: row.localMinute!,
    ),
    final value => throw StateError('Recorrência desconhecida: $value'),
  };
  return domain.Activity(
    id: row.id,
    title: row.title,
    notes: row.notes,
    estimatedDuration: Duration(minutes: row.durationMinutes),
    priority: domain.ActivityPriority.values.byName(row.priority),
    recurrence: recurrence,
    preparationLead: row.preparationLeadMinutes == null
        ? null
        : Duration(minutes: row.preparationLeadMinutes!),
    isActive: row.isActive,
    createdAtUtc: row.createdAtUtc.toUtc(),
    updatedAtUtc: row.updatedAtUtc.toUtc(),
  );
}

OccurrencesCompanion _occurrenceCompanion(ActivityOccurrence occurrence) {
  return OccurrencesCompanion(
    id: Value(occurrence.id),
    nativeAlarmId: Value(NativeAlarmId.fromOccurrenceId(occurrence.id)),
    activityId: Value(occurrence.activityId),
    originalStartUtc: Value(occurrence.originalStartUtc),
    scheduledStartUtc: Value(occurrence.scheduledStartUtc),
    durationMinutes: Value(occurrence.estimatedDuration.inMinutes),
    priority: Value(occurrence.priority.name),
    status: Value(occurrence.status.name),
    attempt: Value(occurrence.attempt),
  );
}

ActivityOccurrence _occurrenceFromRow(OccurrenceRow row) {
  return ActivityOccurrence(
    id: row.id,
    activityId: row.activityId,
    originalStartUtc: row.originalStartUtc.toUtc(),
    scheduledStartUtc: row.scheduledStartUtc.toUtc(),
    estimatedDuration: Duration(minutes: row.durationMinutes),
    priority: domain.ActivityPriority.values.byName(row.priority),
    status: OccurrenceStatus.values.byName(row.status),
    attempt: row.attempt,
  );
}

int _encodeWeekdays(Set<int> weekdays) {
  return weekdays.fold(0, (mask, day) => mask | (1 << (day - 1)));
}

Set<int> _decodeWeekdays(int mask) {
  return {
    for (var day = DateTime.monday; day <= DateTime.sunday; day++)
      if ((mask & (1 << (day - 1))) != 0) day,
  };
}

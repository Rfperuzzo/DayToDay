import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/activity_event.dart';

final class DriftActivityEventRepository implements ActivityEventRepository {
  const DriftActivityEventRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> append(ActivityEvent event) async {
    await _database
        .into(_database.activityEvents)
        .insert(
          ActivityEventsCompanion(
            id: Value(event.id),
            occurrenceId: Value(event.occurrenceId),
            type: Value(event.type.name),
            occurredAtUtc: Value(event.occurredAtUtc.toUtc()),
            previousStartUtc: Value(event.previousStartUtc?.toUtc()),
            nextStartUtc: Value(event.nextStartUtc?.toUtc()),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<List<ActivityEvent>> findForOccurrence(String occurrenceId) async {
    final query = _database.select(_database.activityEvents)
      ..where((table) => table.occurrenceId.equals(occurrenceId))
      ..orderBy([(table) => OrderingTerm.asc(table.occurredAtUtc)]);
    final rows = await query.get();
    return rows
        .map(
          (row) => ActivityEvent(
            id: row.id,
            occurrenceId: row.occurrenceId,
            type: ActivityEventType.values.byName(row.type),
            occurredAtUtc: row.occurredAtUtc.toUtc(),
            previousStartUtc: row.previousStartUtc?.toUtc(),
            nextStartUtc: row.nextStartUtc?.toUtc(),
          ),
        )
        .toList(growable: false);
  }
}

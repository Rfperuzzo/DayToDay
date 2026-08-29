import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/subtask.dart';
import '../domain/subtask_repository.dart';

final class DriftSubtaskRepository implements SubtaskRepository {
  const DriftSubtaskRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(Subtask subtask) async {
    await _database
        .into(_database.subtasks)
        .insertOnConflictUpdate(_companion(subtask));
  }

  @override
  Future<void> delete(String subtaskId) async {
    await (_database.delete(
      _database.subtasks,
    )..where((table) => table.id.equals(subtaskId))).go();
  }

  @override
  Future<List<Subtask>> findForActivity(String activityId) async {
    final query = _database.select(_database.subtasks)
      ..where((table) => table.activityId.equals(activityId))
      ..orderBy([(table) => OrderingTerm.asc(table.position)]);
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Stream<List<Subtask>> watchForActivity(String activityId) {
    final query = _database.select(_database.subtasks)
      ..where((table) => table.activityId.equals(activityId))
      ..orderBy([(table) => OrderingTerm.asc(table.position)]);
    return query.watch().map(
      (rows) => rows.map(_fromRow).toList(growable: false),
    );
  }
}

SubtasksCompanion _companion(Subtask subtask) => SubtasksCompanion(
  id: Value(subtask.id),
  activityId: Value(subtask.activityId),
  title: Value(subtask.title),
  isCompleted: Value(subtask.isCompleted),
  position: Value(subtask.position),
  createdAtUtc: Value(subtask.createdAtUtc),
  completedAtUtc: Value(subtask.completedAtUtc),
);

Subtask _fromRow(SubtaskRow row) => Subtask(
  id: row.id,
  activityId: row.activityId,
  title: row.title,
  isCompleted: row.isCompleted,
  position: row.position,
  createdAtUtc: row.createdAtUtc,
  completedAtUtc: row.completedAtUtc,
);

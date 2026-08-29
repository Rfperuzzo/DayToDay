import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';

void main() {
  late AppDatabase database;
  late DriftActivityRepository activities;
  late DriftOccurrenceRepository occurrences;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    activities = DriftActivityRepository(database);
    occurrences = DriftOccurrenceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('salva e recupera atividade semanal', () async {
    final activity = _activity();

    await activities.save(activity);
    final loaded = await activities.findById(activity.id);

    expect(loaded, isNotNull);
    expect(loaded!.title, 'Medicação');
    expect(loaded.priority, ActivityPriority.high);
    final recurrence = loaded.recurrence as WeeklyRecurrence;
    expect(recurrence.weekdays, {DateTime.monday, DateTime.friday});
    expect(recurrence.hour, 8);
  });

  test('atualiza ocorrência sem criar duplicata', () async {
    final activity = _activity();
    await activities.save(activity);
    final occurrence = ActivityOccurrence(
      id: 'ocorrencia-1',
      activityId: activity.id,
      originalStartUtc: DateTime.utc(2026, 8, 31, 11),
      scheduledStartUtc: DateTime.utc(2026, 8, 31, 11),
      estimatedDuration: const Duration(minutes: 20),
      priority: ActivityPriority.high,
      status: OccurrenceStatus.scheduled,
    );

    await occurrences.saveAll([occurrence]);
    await occurrences.update(
      occurrence.copyWith(
        scheduledStartUtc: DateTime.utc(2026, 8, 31, 12),
        status: OccurrenceStatus.postponed,
        attempt: 1,
      ),
    );

    final loaded = await occurrences.findById(occurrence.id);
    expect(loaded!.attempt, 1);
    expect(loaded.status, OccurrenceStatus.postponed);
    expect(loaded.scheduledStartUtc, DateTime.utc(2026, 8, 31, 12));
  });
}

Activity _activity() {
  return Activity(
    id: 'atividade-1',
    title: 'Medicação',
    estimatedDuration: const Duration(minutes: 20),
    priority: ActivityPriority.high,
    recurrence: WeeklyRecurrence(
      weekdays: const {DateTime.monday, DateTime.friday},
      hour: 8,
      minute: 0,
    ),
    createdAtUtc: DateTime.utc(2026, 8, 29),
    updatedAtUtc: DateTime.utc(2026, 8, 29),
  );
}

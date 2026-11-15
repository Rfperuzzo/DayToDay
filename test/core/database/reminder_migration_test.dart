import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_subtask_repository.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/history/data/drift_activity_event_repository.dart';

void main() {
  for (final version in [1, 2]) {
    test(
      'migra schema $version sem perder dados ou transformar blocos em lembretes',
      () async {
        final sql = File('test/fixtures/schema_v2.sql').readAsStringSync();
        final database = AppDatabase(
          NativeDatabase.memory(
            setup: (db) {
              db.execute(sql);
              if (version == 1) {
                db.execute('DROP TABLE subtasks; PRAGMA user_version=1;');
              }
            },
          ),
        );
        addTearDown(database.close);
        final activities = DriftActivityRepository(database);
        final occurrences = DriftOccurrenceRepository(database);
        final activity = (await activities.findById('legacy'))!;
        expect(activity.kind, ActivityKind.timeBlock);
        expect(activity.title, 'Estudar');
        expect(activity.notes, 'Preservar anotação');
        expect(activity.estimatedDuration, const Duration(minutes: 45));
        expect((activity.recurrence as WeeklyRecurrence).weekdays, {1, 5});
        final old = (await occurrences.findById('legacy:old'))!;
        expect(old.kind, ActivityKind.timeBlock);
        expect(old.status, OccurrenceStatus.completed);
        expect(old.attempt, 2);
        expect(old.acknowledgedAtUtc, isNull);
        expect(old.originalStartUtc.millisecondsSinceEpoch, 1794646800000);
        expect(old.scheduledStartUtc.millisecondsSinceEpoch, 1794650400000);
        final row = await database
            .customSelect('SELECT native_alarm_id FROM occurrences')
            .getSingle();
        expect(row.read<int>('native_alarm_id'), 12345);
        expect(
          await DriftActivityEventRepository(
            database,
          ).findForOccurrence(old.id),
          hasLength(1),
        );
        final subtasks = await DriftSubtaskRepository(
          database,
        ).findForActivity(activity.id);
        expect(subtasks, hasLength(version == 1 ? 0 : 1));
        if (version == 2) expect(subtasks.single.isCompleted, isTrue);
        final settings = await database
            .select(database.userPreferenceRows)
            .getSingle();
        expect(settings.dayStartMinutes, 480);
        expect(settings.maxPendingAlarms, 100);
        expect(
          (await database.select(database.appMetadataRows).getSingle()).value,
          'unchanged',
        );
        expect(
          (await database.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          3,
        );
        await activities.save(
          Activity(
            id: 'new',
            title: 'Água',
            kind: ActivityKind.reminder,
            estimatedDuration: Duration.zero,
            priority: ActivityPriority.normal,
            recurrence: OneOffRecurrence(DateTime.utc(2026, 11, 15)),
            createdAtUtc: DateTime.utc(2026, 11, 14),
            updatedAtUtc: DateTime.utc(2026, 11, 14),
          ),
        );
        expect((await activities.findById('new'))!.isReminder, isTrue);
        expect(
          (await activities.findById('legacy'))!.estimatedDuration,
          const Duration(minutes: 45),
        );
      },
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/home_widget/application/day_widget_snapshot_builder.dart';

void main() {
  test('resume, ordena e bloqueia as tarefas posteriores do widget', () {
    final first = _occurrence('primeira', 9);
    final second = _occurrence('segunda', 10);
    final completed = _occurrence(
      'concluida',
      8,
      status: OccurrenceStatus.completed,
    );

    final snapshot = DayWidgetSnapshotBuilder.build(
      localDay: DateTime(2026, 8, 29),
      activities: [
        _activityFor(first, 'Primeira tarefa'),
        _activityFor(second, 'Segunda tarefa'),
        _activityFor(completed, 'Tarefa concluída'),
      ],
      occurrences: [second, first, completed],
      timeZone: const _UtcTimeZone(),
    );

    expect(snapshot.dayKey, '2026-08-29');
    expect(snapshot.dateLabel, 'sábado, 29');
    expect(snapshot.completedCount, 1);
    expect(snapshot.tasks.map((item) => item.title), [
      'Tarefa concluída',
      'Primeira tarefa',
      'Segunda tarefa',
    ]);
    expect(snapshot.tasks[1].isLocked, isFalse);
    expect(snapshot.tasks[2].isLocked, isTrue);
    expect(snapshot.tasks[1].timeLabel, '09:00');
  });
}

ActivityOccurrence _occurrence(
  String id,
  int hour, {
  OccurrenceStatus status = OccurrenceStatus.scheduled,
}) {
  final start = DateTime.utc(2026, 8, 29, hour);
  return ActivityOccurrence(
    id: id,
    activityId: 'atividade-$id',
    originalStartUtc: start,
    scheduledStartUtc: start,
    estimatedDuration: const Duration(minutes: 45),
    priority: ActivityPriority.normal,
    status: status,
  );
}

Activity _activityFor(ActivityOccurrence occurrence, String title) => Activity(
  id: occurrence.activityId,
  title: title,
  estimatedDuration: occurrence.estimatedDuration,
  priority: occurrence.priority,
  recurrence: OneOffRecurrence(occurrence.scheduledStartUtc),
  createdAtUtc: DateTime.utc(2026, 8, 1),
  updatedAtUtc: DateTime.utc(2026, 8, 1),
);

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

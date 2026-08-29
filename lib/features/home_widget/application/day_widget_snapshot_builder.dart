import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../dashboard/application/daily_task_sequence.dart';
import '../domain/day_widget_gateway.dart';

abstract final class DayWidgetSnapshotBuilder {
  static DayWidgetSnapshot build({
    required DateTime localDay,
    required List<Activity> activities,
    required List<ActivityOccurrence> occurrences,
    required TimeZoneService timeZone,
  }) {
    final sorted = [...occurrences]
      ..sort(
        (left, right) =>
            left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
      );
    final available = DailyTaskSequence.firstAvailable(sorted);
    final activitiesById = {for (final item in activities) item.id: item};
    return DayWidgetSnapshot(
      dayKey: _dayKey(localDay),
      dateLabel: _dateLabel(localDay),
      completedCount: sorted
          .where((item) => item.status == OccurrenceStatus.completed)
          .length,
      tasks: [
        for (final occurrence in sorted)
          DayWidgetTask(
            occurrenceId: occurrence.id,
            activityId: occurrence.activityId,
            title: activitiesById[occurrence.activityId]?.title ?? 'Atividade',
            timeLabel: _timeLabel(
              timeZone.toLocal(occurrence.scheduledStartUtc),
            ),
            durationMinutes: occurrence.estimatedDuration.inMinutes,
            status: occurrence.status.name,
            priority: occurrence.priority.name,
            isLocked: DailyTaskSequence.isLocked(
              occurrence: occurrence,
              available: available,
            ),
          ),
      ],
    );
  }

  static String _timeLabel(DateTime local) =>
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

  static String _dayKey(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';

  static String _dateLabel(DateTime local) {
    const weekdays = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];
    return '${weekdays[local.weekday - 1]}, ${local.day}';
  }
}

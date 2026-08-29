import '../../../core/time/time_zone_service.dart';
import '../domain/activity.dart';
import '../domain/activity_occurrence.dart';
import '../domain/recurrence_rule.dart';

final class OccurrenceGenerator {
  const OccurrenceGenerator(this._timeZone);

  final TimeZoneService _timeZone;

  List<ActivityOccurrence> generate({
    required Activity activity,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) {
    if (!activity.isActive) {
      return const [];
    }

    final normalizedFrom = fromUtc.toUtc();
    final normalizedUntil = untilUtc.toUtc();
    if (!normalizedUntil.isAfter(normalizedFrom)) {
      throw ArgumentError('untilUtc deve ser posterior a fromUtc.');
    }

    return switch (activity.recurrence) {
      OneOffRecurrence recurrence => _generateOneOff(
        activity,
        recurrence,
        normalizedFrom,
        normalizedUntil,
      ),
      WeeklyRecurrence recurrence => _generateWeekly(
        activity,
        recurrence,
        normalizedFrom,
        normalizedUntil,
      ),
    };
  }

  List<ActivityOccurrence> _generateOneOff(
    Activity activity,
    OneOffRecurrence recurrence,
    DateTime fromUtc,
    DateTime untilUtc,
  ) {
    final scheduledAt = recurrence.scheduledAtUtc;
    if (scheduledAt.isBefore(fromUtc) || !scheduledAt.isBefore(untilUtc)) {
      return const [];
    }
    return [_createOccurrence(activity, scheduledAt)];
  }

  List<ActivityOccurrence> _generateWeekly(
    Activity activity,
    WeeklyRecurrence recurrence,
    DateTime fromUtc,
    DateTime untilUtc,
  ) {
    final localFrom = _timeZone.toLocal(fromUtc);
    final localUntil = _timeZone.toLocal(untilUtc);
    var date = DateTime(localFrom.year, localFrom.month, localFrom.day);
    final finalDate = DateTime(
      localUntil.year,
      localUntil.month,
      localUntil.day,
    );
    final result = <ActivityOccurrence>[];

    while (!date.isAfter(finalDate)) {
      if (recurrence.weekdays.contains(date.weekday)) {
        final localScheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          recurrence.hour,
          recurrence.minute,
        );
        final scheduledAtUtc = _timeZone.localComponentsToUtc(localScheduledAt);
        if (!scheduledAtUtc.isBefore(fromUtc) &&
            scheduledAtUtc.isBefore(untilUtc)) {
          result.add(_createOccurrence(activity, scheduledAtUtc));
        }
      }
      date = date.add(const Duration(days: 1));
    }

    return result;
  }

  ActivityOccurrence _createOccurrence(
    Activity activity,
    DateTime scheduledAtUtc,
  ) {
    final normalized = scheduledAtUtc.toUtc();
    return ActivityOccurrence(
      id: '${activity.id}:${normalized.microsecondsSinceEpoch}',
      activityId: activity.id,
      originalStartUtc: normalized,
      scheduledStartUtc: normalized,
      estimatedDuration: activity.estimatedDuration,
      priority: activity.priority,
      status: OccurrenceStatus.scheduled,
    );
  }
}

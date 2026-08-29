import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/routine_planner.dart';

final class PriorityRoutinePlanner implements RoutinePlanner {
  const PriorityRoutinePlanner(this._timeZone);

  final TimeZoneService _timeZone;

  @override
  RoutinePlan replanNowNot({
    required ActivityOccurrence occurrence,
    required Iterable<ActivityOccurrence> existingOccurrences,
    required DateTime nowUtc,
    required UserPreferences preferences,
  }) {
    final normalizedNow = nowUtc.toUtc();
    final nextAttempt = occurrence.attempt + 1;
    final localNow = _timeZone.toLocal(normalizedNow);
    final firstAllowedLocal = nextAttempt > preferences.maxSameDayReplans
        ? _atDayMinute(
            DateTime(localNow.year, localNow.month, localNow.day + 1),
            preferences.dayStartMinutes,
          )
        : _roundUpToFiveMinutes(
            localNow,
          ).isBefore(_atDayMinute(localNow, preferences.dayStartMinutes))
        ? _atDayMinute(localNow, preferences.dayStartMinutes)
        : _roundUpToFiveMinutes(localNow);
    final firstAllowedUtc = _timeZone.localComponentsToUtc(firstAllowedLocal);

    final replanned = occurrence.copyWith(
      scheduledStartUtc: firstAllowedUtc,
      status: OccurrenceStatus.scheduled,
      attempt: nextAttempt,
    );
    final candidates = <_Candidate>[
      _Candidate(replanned, firstAllowedUtc, isTarget: true),
      for (final existing in existingOccurrences)
        if (existing.id != occurrence.id &&
            _blocksTime(existing) &&
            existing.scheduledEndUtc.isAfter(normalizedNow))
          _Candidate(existing, existing.scheduledStartUtc.toUtc()),
    ]..sort(_compareCandidates);

    final placed = <ActivityOccurrence>[];
    final adjusted = <ActivityOccurrence>[];
    ActivityOccurrence? target;

    for (final candidate in candidates) {
      final scheduledAt = _findSlot(
        earliestUtc: candidate.earliestUtc,
        duration: candidate.occurrence.estimatedDuration,
        placed: placed,
        preferences: preferences,
      );
      final scheduled = candidate.occurrence.copyWith(
        scheduledStartUtc: scheduledAt,
      );
      placed.add(scheduled);
      if (candidate.isTarget ||
          scheduledAt != candidate.occurrence.scheduledStartUtc) {
        adjusted.add(scheduled);
      }
      if (candidate.isTarget) {
        target = scheduled;
      }
    }

    adjusted.sort(
      (left, right) =>
          left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
    );
    return RoutinePlan(
      rescheduled: target!,
      adjustedOccurrences: List.unmodifiable(adjusted),
    );
  }

  DateTime _findSlot({
    required DateTime earliestUtc,
    required Duration duration,
    required List<ActivityOccurrence> placed,
    required UserPreferences preferences,
  }) {
    final earliestLocal = _timeZone.toLocal(earliestUtc);
    final firstDate = DateTime(
      earliestLocal.year,
      earliestLocal.month,
      earliestLocal.day,
    );

    for (var offset = 0; offset < preferences.scheduleHorizonDays; offset++) {
      final date = firstDate.add(Duration(days: offset));
      final dayStartLocal = _atDayMinute(date, preferences.dayStartMinutes);
      final dayEndLocal = _atDayMinute(date, preferences.dayEndMinutes);
      final earliestForDay = offset == 0 && earliestLocal.isAfter(dayStartLocal)
          ? _roundUpToFiveMinutes(earliestLocal)
          : dayStartLocal;
      var cursorUtc = _timeZone.localComponentsToUtc(earliestForDay);
      final dayEndUtc = _timeZone.localComponentsToUtc(dayEndLocal);
      final blocks =
          placed
              .where(
                (item) =>
                    item.scheduledEndUtc.isAfter(cursorUtc) &&
                    item.scheduledStartUtc.isBefore(dayEndUtc),
              )
              .toList()
            ..sort(
              (left, right) =>
                  left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
            );

      for (final block in blocks) {
        if (!cursorUtc.add(duration).isAfter(block.scheduledStartUtc)) {
          return cursorUtc;
        }
        if (cursorUtc.isBefore(block.scheduledEndUtc)) {
          cursorUtc = block.scheduledEndUtc;
        }
      }
      if (!cursorUtc.add(duration).isAfter(dayEndUtc)) {
        return cursorUtc;
      }
    }

    throw StateError('Não há espaço livre dentro do horizonte configurado.');
  }
}

final class _Candidate {
  const _Candidate(this.occurrence, this.earliestUtc, {this.isTarget = false});

  final ActivityOccurrence occurrence;
  final DateTime earliestUtc;
  final bool isTarget;
}

int _compareCandidates(_Candidate left, _Candidate right) {
  final priority = right.occurrence.priority.index.compareTo(
    left.occurrence.priority.index,
  );
  if (priority != 0) {
    return priority;
  }
  final time = left.earliestUtc.compareTo(right.earliestUtc);
  if (time != 0) {
    return time;
  }
  return left.occurrence.id.compareTo(right.occurrence.id);
}

bool _blocksTime(ActivityOccurrence occurrence) {
  return switch (occurrence.status) {
    OccurrenceStatus.scheduled ||
    OccurrenceStatus.ringing ||
    OccurrenceStatus.postponed => true,
    OccurrenceStatus.completed ||
    OccurrenceStatus.skipped ||
    OccurrenceStatus.cancelled => false,
  };
}

DateTime _atDayMinute(DateTime date, int minuteOfDay) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );
}

DateTime _roundUpToFiveMinutes(DateTime value) {
  final remainder = value.minute % 5;
  final hasSubMinute =
      value.second != 0 || value.millisecond != 0 || value.microsecond != 0;
  final minutesToAdd = remainder == 0 && !hasSubMinute ? 0 : 5 - remainder;
  return DateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
  ).add(Duration(minutes: minutesToAdd));
}

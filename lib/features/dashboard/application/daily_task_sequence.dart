import '../../activities/domain/activity_occurrence.dart';

abstract final class DailyTaskSequence {
  static ActivityOccurrence? firstAvailable(
    Iterable<ActivityOccurrence> occurrences,
  ) {
    final sorted = [...occurrences]
      ..sort(
        (left, right) =>
            left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
      );
    for (final occurrence in sorted) {
      if (_isPending(occurrence.status)) {
        return occurrence;
      }
    }
    return null;
  }

  static bool isLocked({
    required ActivityOccurrence occurrence,
    required ActivityOccurrence? available,
  }) => _isPending(occurrence.status) && occurrence.id != available?.id;

  static bool _isPending(OccurrenceStatus status) => switch (status) {
    OccurrenceStatus.scheduled ||
    OccurrenceStatus.ringing ||
    OccurrenceStatus.postponed => true,
    OccurrenceStatus.completed ||
    OccurrenceStatus.skipped ||
    OccurrenceStatus.cancelled => false,
  };
}

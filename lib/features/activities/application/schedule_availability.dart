import '../domain/activity_occurrence.dart';

final class ScheduleConflictException implements Exception {
  const ScheduleConflictException({
    required this.candidate,
    required this.blocking,
  });

  final ActivityOccurrence candidate;
  final ActivityOccurrence blocking;

  DateTime get nextAvailableUtc => blocking.scheduledEndUtc;

  @override
  String toString() =>
      'A duração ocupa um horário já reservado. Próximo início possível: $nextAvailableUtc.';
}

abstract final class ScheduleAvailability {
  static void ensureAvailable({
    required Iterable<ActivityOccurrence> candidates,
    required Iterable<ActivityOccurrence> existing,
    String? ignoredActivityId,
  }) {
    for (final candidate in candidates) {
      for (final blocking in existing) {
        if (blocking.activityId == ignoredActivityId ||
            !_blocksTime(blocking.status)) {
          continue;
        }
        final overlaps =
            candidate.scheduledStartUtc.isBefore(blocking.scheduledEndUtc) &&
            candidate.scheduledEndUtc.isAfter(blocking.scheduledStartUtc);
        if (overlaps) {
          throw ScheduleConflictException(
            candidate: candidate,
            blocking: blocking,
          );
        }
      }
    }
  }

  static bool _blocksTime(OccurrenceStatus status) => switch (status) {
    OccurrenceStatus.scheduled ||
    OccurrenceStatus.ringing ||
    OccurrenceStatus.postponed => true,
    OccurrenceStatus.completed ||
    OccurrenceStatus.skipped ||
    OccurrenceStatus.cancelled => false,
  };
}

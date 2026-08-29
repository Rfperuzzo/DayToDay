import 'activity.dart';

enum OccurrenceStatus {
  scheduled,
  ringing,
  completed,
  postponed,
  skipped,
  cancelled,
}

final class ActivityOccurrence {
  const ActivityOccurrence({
    required this.id,
    required this.activityId,
    required this.originalStartUtc,
    required this.scheduledStartUtc,
    required this.estimatedDuration,
    required this.priority,
    required this.status,
    this.attempt = 0,
  });

  final String id;
  final String activityId;
  final DateTime originalStartUtc;
  final DateTime scheduledStartUtc;
  final Duration estimatedDuration;
  final ActivityPriority priority;
  final OccurrenceStatus status;
  final int attempt;

  DateTime get scheduledEndUtc => scheduledStartUtc.add(estimatedDuration);

  ActivityOccurrence copyWith({
    DateTime? scheduledStartUtc,
    OccurrenceStatus? status,
    int? attempt,
  }) {
    return ActivityOccurrence(
      id: id,
      activityId: activityId,
      originalStartUtc: originalStartUtc,
      scheduledStartUtc: scheduledStartUtc ?? this.scheduledStartUtc,
      estimatedDuration: estimatedDuration,
      priority: priority,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
    );
  }
}

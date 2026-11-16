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
    this.kind = ActivityKind.timeBlock,
    this.acknowledgedAtUtc,
    this.endAcknowledgedAtUtc,
    this.notifyAtStart = true,
    this.notifyAtEnd = false,
    this.usesBoundaryAlarms = false,
  });

  final ActivityKind kind;
  final DateTime? acknowledgedAtUtc;
  final DateTime? endAcknowledgedAtUtc;
  final bool notifyAtStart;
  final bool notifyAtEnd;
  final bool usesBoundaryAlarms;
  bool get isReminder => kind == ActivityKind.reminder;
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
    DateTime? acknowledgedAtUtc,
    DateTime? endAcknowledgedAtUtc,
  }) {
    return ActivityOccurrence(
      kind: kind,
      notifyAtStart: notifyAtStart,
      notifyAtEnd: notifyAtEnd,
      usesBoundaryAlarms: usesBoundaryAlarms,
      endAcknowledgedAtUtc:
          scheduledStartUtc != null &&
              scheduledStartUtc != this.scheduledStartUtc
          ? null
          : endAcknowledgedAtUtc ?? this.endAcknowledgedAtUtc,
      acknowledgedAtUtc:
          scheduledStartUtc != null &&
              scheduledStartUtc != this.scheduledStartUtc
          ? null
          : acknowledgedAtUtc ?? this.acknowledgedAtUtc,
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

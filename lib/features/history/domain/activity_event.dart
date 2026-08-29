enum ActivityEventType {
  completed,
  nowNot,
  skipped,
  automaticallyRescheduled,
  alarmDropped,
  edited,
  cancelled,
}

final class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.occurrenceId,
    required this.type,
    required this.occurredAtUtc,
    this.previousStartUtc,
    this.nextStartUtc,
  });

  final String id;
  final String occurrenceId;
  final ActivityEventType type;
  final DateTime occurredAtUtc;
  final DateTime? previousStartUtc;
  final DateTime? nextStartUtc;
}

abstract interface class ActivityEventRepository {
  Future<void> append(ActivityEvent event);

  Future<List<ActivityEvent>> findForOccurrence(String occurrenceId);
}

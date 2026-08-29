final class DayWidgetTask {
  const DayWidgetTask({
    required this.occurrenceId,
    required this.activityId,
    required this.title,
    required this.timeLabel,
    required this.durationMinutes,
    required this.status,
    required this.priority,
    required this.isLocked,
  });

  final String occurrenceId;
  final String activityId;
  final String title;
  final String timeLabel;
  final int durationMinutes;
  final String status;
  final String priority;
  final bool isLocked;

  Map<String, Object> toJson() => {
    'occurrenceId': occurrenceId,
    'activityId': activityId,
    'title': title,
    'timeLabel': timeLabel,
    'durationMinutes': durationMinutes,
    'status': status,
    'priority': priority,
    'isLocked': isLocked,
  };
}

final class DayWidgetSnapshot {
  const DayWidgetSnapshot({
    required this.dayKey,
    required this.dateLabel,
    required this.completedCount,
    required this.tasks,
  });

  final String dayKey;
  final String dateLabel;
  final int completedCount;
  final List<DayWidgetTask> tasks;

  Map<String, Object> toJson() => {
    'dayKey': dayKey,
    'dateLabel': dateLabel,
    'completedCount': completedCount,
    'totalCount': tasks.length,
    'tasks': tasks.map((item) => item.toJson()).toList(growable: false),
  };
}

final class DayWidgetBundle {
  const DayWidgetBundle({required this.days});

  final List<DayWidgetSnapshot> days;

  Map<String, Object> toJson() => {
    'days': days.map((item) => item.toJson()).toList(growable: false),
  };
}

final class DayWidgetOpenRequest {
  const DayWidgetOpenRequest({
    required this.occurrenceId,
    required this.activityId,
  });

  final String occurrenceId;
  final String activityId;
}

abstract interface class DayWidgetGateway {
  Stream<DayWidgetOpenRequest> get openRequests;

  Future<void> initialize();

  Future<void> update(DayWidgetBundle bundle);

  Future<void> acknowledgeOpenRequest();
}

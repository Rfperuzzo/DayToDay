enum AlarmPlatformEventType { moved, dropped }

enum AlarmPlatformEventCause { snooze, platformRefusal, staleAtBoot }

final class AlarmRequest {
  const AlarmRequest({
    required this.occurrenceId,
    required this.scheduledAtUtc,
    required this.title,
    required this.body,
  });

  final String occurrenceId;
  final DateTime scheduledAtUtc;
  final String title;
  final String body;
}

final class ScheduledAlarmBinding {
  const ScheduledAlarmBinding({
    required this.occurrenceId,
    required this.nativeAlarmId,
    required this.scheduledAtUtc,
  });

  final String occurrenceId;
  final int nativeAlarmId;
  final DateTime scheduledAtUtc;
}

final class RingingAlarmBinding {
  const RingingAlarmBinding({
    required this.occurrenceId,
    required this.nativeAlarmId,
    required this.scheduledAtUtc,
    required this.title,
    required this.body,
  });

  final String occurrenceId;
  final int nativeAlarmId;
  final DateTime scheduledAtUtc;
  final String title;
  final String body;
}

final class AlarmPlatformEvent {
  const AlarmPlatformEvent({
    required this.key,
    required this.nativeAlarmId,
    required this.type,
    required this.cause,
    required this.recordedAtUtc,
    required this.alarmTimeUtc,
  });

  final String key;
  final int nativeAlarmId;
  final AlarmPlatformEventType type;
  final AlarmPlatformEventCause cause;
  final DateTime recordedAtUtc;
  final DateTime alarmTimeUtc;
}

abstract interface class AlarmGateway {
  Stream<AlarmPlatformEvent> get events;

  Stream<List<RingingAlarmBinding>> get ringing;

  Future<void> initialize();

  Future<void> schedule(AlarmRequest request);

  Future<void> cancel(String occurrenceId);

  Future<List<ScheduledAlarmBinding>> scheduled();

  Future<void> acknowledge(AlarmPlatformEvent event);
}

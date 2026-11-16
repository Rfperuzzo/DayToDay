enum AlarmPhase { start, end, transition }

abstract final class AlarmIdentity {
  static String endKey(String occurrenceId) => '#end:$occurrenceId';
  static String key(String occurrenceId, AlarmPhase phase) =>
      phase == AlarmPhase.end ? endKey(occurrenceId) : occurrenceId;
}

enum AlarmPlatformEventType { moved, dropped }

enum AlarmPlatformEventCause { snooze, platformRefusal, staleAtBoot }

final class AlarmRequest {
  const AlarmRequest({
    required this.occurrenceId,
    this.phase = AlarmPhase.start,
    this.previousOccurrenceId,
    required this.scheduledAtUtc,
    required this.estimatedDuration,
    required this.title,
    required this.body,
  });

  final String occurrenceId;
  final AlarmPhase phase;
  final String? previousOccurrenceId;
  String get alarmKey => AlarmIdentity.key(occurrenceId, phase);
  final DateTime scheduledAtUtc;
  final Duration estimatedDuration;
  final String title;
  final String body;
}

final class ScheduledAlarmBinding {
  const ScheduledAlarmBinding({
    required this.occurrenceId,
    this.phase = AlarmPhase.start,
    this.previousOccurrenceId,
    required this.nativeAlarmId,
    required this.scheduledAtUtc,
    this.title,
    this.body,
  });

  final String occurrenceId;
  final AlarmPhase phase;
  final String? previousOccurrenceId;
  String get alarmKey => AlarmIdentity.key(occurrenceId, phase);
  final int nativeAlarmId;
  final DateTime scheduledAtUtc;
  final String? title;
  final String? body;
}

final class RingingAlarmBinding {
  const RingingAlarmBinding({
    required this.occurrenceId,
    this.phase = AlarmPhase.start,
    this.previousOccurrenceId,
    required this.nativeAlarmId,
    required this.scheduledAtUtc,
    required this.title,
    required this.body,
    this.estimatedDuration,
  });

  final String occurrenceId;
  final AlarmPhase phase;
  final String? previousOccurrenceId;
  String get alarmKey => AlarmIdentity.key(occurrenceId, phase);
  final int nativeAlarmId;
  final DateTime scheduledAtUtc;
  final String title;
  final String body;
  final Duration? estimatedDuration;
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

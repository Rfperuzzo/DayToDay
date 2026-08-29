import 'dart:async';
import 'dart:convert';

import 'package:alarm/alarm.dart' as alarm;

import '../domain/alarm_gateway.dart';
import 'native_alarm_id.dart';

final class AndroidAlarmGateway implements AlarmGateway {
  final _events = StreamController<AlarmPlatformEvent>.broadcast();
  final _nativeEvents = <String, alarm.AlarmEvent>{};
  StreamSubscription<alarm.AlarmEvent>? _subscription;
  bool _initialized = false;

  @override
  Stream<AlarmPlatformEvent> get events => _events.stream;

  @override
  Stream<List<RingingAlarmBinding>> get ringing => alarm.Alarm.ringing.map((
    alarmSet,
  ) {
    final bindings =
        [
          for (final item in alarmSet.alarms)
            if (_occurrenceIdFromPayload(item.payload) case final occurrenceId?)
              RingingAlarmBinding(
                occurrenceId: occurrenceId,
                nativeAlarmId: item.id,
                scheduledAtUtc: item.dateTime.toUtc(),
                title: item.notificationSettings.title,
                body: item.notificationSettings.body,
                estimatedDuration: _durationFromPayload(item.payload),
              ),
        ]..sort(
          (left, right) => left.scheduledAtUtc.compareTo(right.scheduledAtUtc),
        );
    return List.unmodifiable(bindings);
  });

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await alarm.Alarm.init(acknowledgeEventsAutomatically: false);
    _subscription = alarm.Alarm.events.listen(_handleNativeEvent);
    _initialized = true;
  }

  @override
  Future<void> schedule(AlarmRequest request) async {
    _ensureInitialized();
    final success = await alarm.Alarm.set(
      alarmSettings: alarm.AlarmSettings(
        id: NativeAlarmId.fromOccurrenceId(request.occurrenceId),
        dateTime: request.scheduledAtUtc.toLocal(),
        assetAudioPath: null,
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: false,
        androidFullScreenIntent: true,
        allowAlarmOverlap: false,
        allowSameSecondScheduling: false,
        androidStopAlarmOnTermination: false,
        preferConnectedAudioDevice: false,
        androidStaleAfter: alarm.AlarmSettings.defaultStaleAfter,
        payload: jsonEncode({
          'occurrenceId': request.occurrenceId,
          'durationMinutes': request.estimatedDuration.inMinutes,
        }),
        volumeSettings: alarm.VolumeSettings.fade(
          fadeDuration: Duration(seconds: 5),
          volume: 1.0,
          volumeEnforced: true,
          showSystemUI: false,
        ),
        notificationSettings: alarm.NotificationSettings(
          title: request.title,
          body: request.body,
          stopButton: 'Parar alarme',
          androidStopAlarmOnDismiss: false,
        ),
      ),
    );
    if (!success) {
      throw StateError('O Android recusou o agendamento do alarme.');
    }
  }

  @override
  Future<void> cancel(String occurrenceId) async {
    _ensureInitialized();
    await alarm.Alarm.stop(NativeAlarmId.fromOccurrenceId(occurrenceId));
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async {
    _ensureInitialized();
    final nativeAlarms = await alarm.Alarm.getAlarms();
    return [
      for (final item in nativeAlarms)
        if (_occurrenceIdFromPayload(item.payload) case final occurrenceId?)
          ScheduledAlarmBinding(
            occurrenceId: occurrenceId,
            nativeAlarmId: item.id,
            scheduledAtUtc: item.dateTime.toUtc(),
          ),
    ];
  }

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {
    final native = _nativeEvents.remove(event.key);
    if (native != null) {
      await alarm.Alarm.acknowledgeEvent(native);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }

  void _handleNativeEvent(alarm.AlarmEvent native) {
    final recordedAtUtc = native.recordedAt.toUtc();
    final key = '${native.id}:${recordedAtUtc.microsecondsSinceEpoch}';
    _nativeEvents[key] = native;
    final type = native is alarm.AlarmMoved
        ? AlarmPlatformEventType.moved
        : AlarmPlatformEventType.dropped;
    final alarmTime = switch (native) {
      alarm.AlarmMoved(:final nextRingAt) => nextRingAt,
      alarm.AlarmDropped(:final scheduledFor) => scheduledFor,
    };
    _events.add(
      AlarmPlatformEvent(
        key: key,
        nativeAlarmId: native.id,
        type: type,
        cause: switch (native.cause) {
          alarm.AlarmEventCause.snooze => AlarmPlatformEventCause.snooze,
          alarm.AlarmEventCause.platformRefusal =>
            AlarmPlatformEventCause.platformRefusal,
          alarm.AlarmEventCause.staleAtBoot =>
            AlarmPlatformEventCause.staleAtBoot,
        },
        recordedAtUtc: recordedAtUtc,
        alarmTimeUtc: alarmTime.toUtc(),
      ),
    );
  }

  String? _occurrenceIdFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic>
          ? decoded['occurrenceId'] as String?
          : null;
    } on FormatException {
      return null;
    }
  }

  Duration? _durationFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      final minutes = decoded is Map<String, dynamic>
          ? decoded['durationMinutes'] as int?
          : null;
      return minutes == null || minutes <= 0
          ? null
          : Duration(minutes: minutes);
    } on FormatException {
      return null;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('AlarmGateway precisa ser inicializado antes do uso.');
    }
  }
}

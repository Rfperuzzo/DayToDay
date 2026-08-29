import 'dart:async';

import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../history/domain/activity_event.dart';
import '../domain/alarm_gateway.dart';

final class AlarmEventProcessor {
  AlarmEventProcessor({
    required OccurrenceRepository occurrences,
    required ActivityEventRepository events,
    required AlarmGateway alarms,
  }) : this._(occurrences, events, alarms);

  AlarmEventProcessor._(this._occurrences, this._events, this._alarms);

  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  StreamSubscription<void>? _subscription;

  void start() {
    _subscription ??= _alarms.events.asyncMap(_process).listen((_) {});
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> _process(AlarmPlatformEvent platformEvent) async {
    final occurrence = await _occurrences.findByNativeAlarmId(
      platformEvent.nativeAlarmId,
    );
    if (occurrence == null) {
      await _alarms.acknowledge(platformEvent);
      return;
    }

    final updated = switch (platformEvent.type) {
      AlarmPlatformEventType.moved => occurrence.copyWith(
        scheduledStartUtc: platformEvent.alarmTimeUtc,
        status: OccurrenceStatus.scheduled,
      ),
      AlarmPlatformEventType.dropped => occurrence.copyWith(
        status: OccurrenceStatus.cancelled,
      ),
    };
    await _occurrences.update(updated);
    await _events.append(
      ActivityEvent(
        id: platformEvent.key,
        occurrenceId: occurrence.id,
        type: platformEvent.type == AlarmPlatformEventType.moved
            ? ActivityEventType.automaticallyRescheduled
            : ActivityEventType.alarmDropped,
        occurredAtUtc: platformEvent.recordedAtUtc,
        previousStartUtc: occurrence.scheduledStartUtc,
        nextStartUtc: platformEvent.type == AlarmPlatformEventType.moved
            ? platformEvent.alarmTimeUtc
            : null,
      ),
    );
    await _alarms.acknowledge(platformEvent);
  }
}

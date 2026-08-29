import '../../../core/time/clock.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../alarms/domain/alarm_gateway.dart';
import '../../history/domain/activity_event.dart';

final class OccurrenceActions {
  const OccurrenceActions({
    required this._occurrences,
    required this._events,
    required this._alarms,
    required this._clock,
  });

  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  final Clock _clock;

  Future<void> complete(ActivityOccurrence occurrence) async {
    if (occurrence.status == OccurrenceStatus.completed) {
      return;
    }
    final now = _clock.nowUtc();
    await _occurrences.update(
      occurrence.copyWith(status: OccurrenceStatus.completed),
    );
    await _alarms.cancel(occurrence.id);
    await _events.append(
      ActivityEvent(
        id: '${occurrence.id}:completed:${now.microsecondsSinceEpoch}',
        occurrenceId: occurrence.id,
        type: ActivityEventType.completed,
        occurredAtUtc: now,
      ),
    );
  }
}

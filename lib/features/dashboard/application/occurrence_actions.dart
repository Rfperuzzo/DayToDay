import '../../../core/time/clock.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../alarms/domain/alarm_gateway.dart';
import '../../alarms/application/alarm_reconciler.dart';
import '../../history/domain/activity_event.dart';
import '../../settings/domain/user_preferences.dart';

final class OccurrenceActions {
  const OccurrenceActions({
    required this._occurrences,
    required this._events,
    required this._alarms,
    required this._alarmReconciler,
    required this._clock,
    required this._preferences,
  });

  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  final AlarmReconciler _alarmReconciler;
  final Clock _clock;
  final UserPreferences _preferences;

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
    try {
      await _alarmReconciler.reconcile(_preferences);
    } catch (_) {
      // A conclusão permanece salva mesmo quando o Android limita o alarme.
    }
  }
}

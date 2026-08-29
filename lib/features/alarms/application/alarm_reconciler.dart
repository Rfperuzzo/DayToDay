import '../../../core/time/clock.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/alarm_gateway.dart';
import '../infrastructure/native_alarm_id.dart';

final class AlarmReconciler {
  const AlarmReconciler({
    required ActivityRepository activities,
    required OccurrenceRepository occurrences,
    required AlarmGateway alarms,
    required Clock clock,
  }) : this._(activities, occurrences, alarms, clock);

  const AlarmReconciler._(
    this._activities,
    this._occurrences,
    this._alarms,
    this._clock,
  );

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final AlarmGateway _alarms;
  final Clock _clock;

  Future<void> reconcile(UserPreferences preferences) async {
    final now = _clock.nowUtc();
    final until = now.add(Duration(days: preferences.scheduleHorizonDays));
    final desired = await _occurrences.findScheduledBetween(now, until);
    desired.sort(
      (left, right) =>
          left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
    );
    final limited = desired.take(preferences.maxPendingAlarms).toList();
    _validateNativeIds(limited.map((item) => item.id));

    final existing = {
      for (final item in await _alarms.scheduled()) item.occurrenceId: item,
    };
    final desiredIds = limited.map((item) => item.id).toSet();

    for (final stale in existing.keys.where(
      (occurrenceId) => !desiredIds.contains(occurrenceId),
    )) {
      await _alarms.cancel(stale);
    }

    for (final occurrence in limited) {
      final binding = existing[occurrence.id];
      if (binding?.scheduledAtUtc == occurrence.scheduledStartUtc) {
        continue;
      }
      final activity = await _activities.findById(occurrence.activityId);
      await _alarms.schedule(
        AlarmRequest(
          occurrenceId: occurrence.id,
          scheduledAtUtc: occurrence.scheduledStartUtc,
          title: activity?.title ?? 'Atividade da Jhenifer',
          body: 'Hora da sua atividade. Abra para responder.',
        ),
      );
    }
  }

  void _validateNativeIds(Iterable<String> occurrenceIds) {
    final seen = <int, String>{};
    for (final occurrenceId in occurrenceIds) {
      final nativeId = NativeAlarmId.fromOccurrenceId(occurrenceId);
      final previous = seen[nativeId];
      if (previous != null && previous != occurrenceId) {
        throw StateError(
          'Colisão de identificador de alarme entre $previous e $occurrenceId.',
        );
      }
      seen[nativeId] = occurrenceId;
    }
  }
}

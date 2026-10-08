import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity_occurrence.dart';
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
    required TimeZoneService timeZone,
  }) : this._(activities, occurrences, alarms, clock, timeZone);

  const AlarmReconciler._(
    this._activities,
    this._occurrences,
    this._alarms,
    this._clock,
    this._timeZone,
  );

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final AlarmGateway _alarms;
  final Clock _clock;
  final TimeZoneService _timeZone;

  Future<void> reconcile(UserPreferences preferences) async {
    final now = _clock.nowUtc();
    final until = now.add(Duration(days: preferences.scheduleHorizonDays));
    final desired = await _occurrences.findScheduledBetween(now, until);
    desired.sort(
      (left, right) =>
          left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
    );
    final sequential = _firstOccurrenceOfEachDay(desired);
    final limited = sequential.take(preferences.maxPendingAlarms).toList();
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
          estimatedDuration: occurrence.estimatedDuration,
          title: activity?.title ?? 'Atividade do DayToDay',
          body: 'Hora da sua atividade. Abra para responder.',
        ),
      );
    }
  }

  List<ActivityOccurrence> _firstOccurrenceOfEachDay(
    List<ActivityOccurrence> occurrences,
  ) {
    final seenDays = <String>{};
    return [
      for (final occurrence in occurrences)
        if (seenDays.add(_localDayKey(occurrence.scheduledStartUtc)))
          occurrence,
    ];
  }

  String _localDayKey(DateTime utc) {
    final local = _timeZone.toLocal(utc);
    return '${local.year}-${local.month}-${local.day}';
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

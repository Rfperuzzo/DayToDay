import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../alarms/application/alarm_reconciler.dart';
import '../../alarms/domain/alarm_gateway.dart';
import '../../history/domain/activity_event.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/routine_planner.dart';

final class MissedTaskRecoveryResult {
  const MissedTaskRecoveryResult({
    required this.recovered,
    required this.adjustedOccurrences,
    required this.alarmsSynchronized,
  });

  final ActivityOccurrence recovered;
  final List<ActivityOccurrence> adjustedOccurrences;
  final bool alarmsSynchronized;
}

final class MissedTaskRecoveryService {
  const MissedTaskRecoveryService({
    required OccurrenceRepository occurrences,
    required ActivityEventRepository events,
    required AlarmGateway alarms,
    required AlarmReconciler alarmReconciler,
    required RoutinePlanner planner,
    required TimeZoneService timeZone,
    required Clock clock,
    required UserPreferences preferences,
  }) : this._(
         occurrences,
         events,
         alarms,
         alarmReconciler,
         planner,
         timeZone,
         clock,
         preferences,
       );

  const MissedTaskRecoveryService._(
    this._occurrences,
    this._events,
    this._alarms,
    this._alarmReconciler,
    this._planner,
    this._timeZone,
    this._clock,
    this._preferences,
  );

  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  final AlarmReconciler _alarmReconciler;
  final RoutinePlanner _planner;
  final TimeZoneService _timeZone;
  final Clock _clock;
  final UserPreferences _preferences;

  Future<MissedTaskRecoveryResult?> recover(
    String occurrenceId, {
    DateTime? detectedAtUtc,
  }) async {
    final occurrence = await _occurrences.findById(occurrenceId);
    if (occurrence == null || !_isPending(occurrence.status)) {
      return null;
    }
    final detectedAt = (detectedAtUtc ?? _clock.nowUtc()).toUtc();
    final localDay = _timeZone.toLocal(occurrence.scheduledStartUtc);
    final nextLocalDay = DateTime(
      localDay.year,
      localDay.month,
      localDay.day + 1,
    );
    final dayEndUtc = _timeZone.localComponentsToUtc(nextLocalDay);
    final following = await _occurrences.findScheduledBetween(
      occurrence.scheduledStartUtc,
      dayEndUtc,
    );
    final previousById = {
      occurrence.id: occurrence,
      for (final item in following) item.id: item,
    };
    final plan = _planner.replanMissed(
      occurrence: occurrence,
      followingOccurrences: following,
      nowUtc: detectedAt,
    );

    await _occurrences.saveAll(plan.adjustedOccurrences);
    await _events.append(
      ActivityEvent(
        id: '${occurrence.id}:missed:${detectedAt.microsecondsSinceEpoch}',
        occurrenceId: occurrence.id,
        type: ActivityEventType.missed,
        occurredAtUtc: detectedAt,
        previousStartUtc: occurrence.scheduledStartUtc,
        nextStartUtc: plan.rescheduled.scheduledStartUtc,
      ),
    );
    for (final adjusted in plan.adjustedOccurrences.where(
      (item) => item.id != occurrence.id,
    )) {
      final previous = previousById[adjusted.id];
      if (previous?.scheduledStartUtc == adjusted.scheduledStartUtc) {
        continue;
      }
      await _events.append(
        ActivityEvent(
          id: '${adjusted.id}:missedCascade:${detectedAt.microsecondsSinceEpoch}',
          occurrenceId: adjusted.id,
          type: ActivityEventType.automaticallyRescheduled,
          occurredAtUtc: detectedAt,
          previousStartUtc: previous?.scheduledStartUtc,
          nextStartUtc: adjusted.scheduledStartUtc,
        ),
      );
    }

    var alarmsSynchronized = true;
    try {
      await _alarms.cancel(occurrence.id);
      await _alarmReconciler.reconcile(_preferences);
    } catch (_) {
      alarmsSynchronized = false;
    }
    return MissedTaskRecoveryResult(
      recovered: plan.rescheduled,
      adjustedOccurrences: plan.adjustedOccurrences,
      alarmsSynchronized: alarmsSynchronized,
    );
  }

  bool _isPending(OccurrenceStatus status) => switch (status) {
    OccurrenceStatus.scheduled ||
    OccurrenceStatus.ringing ||
    OccurrenceStatus.postponed => true,
    OccurrenceStatus.completed ||
    OccurrenceStatus.skipped ||
    OccurrenceStatus.cancelled => false,
  };
}

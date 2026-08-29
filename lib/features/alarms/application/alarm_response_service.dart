import '../../../core/time/clock.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/activity_repositories.dart';
import '../../history/domain/activity_event.dart';
import '../../routine_engine/domain/routine_planner.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/alarm_gateway.dart';
import 'alarm_reconciler.dart';

enum AlarmResponse { complete, nowNot, skipToday }

final class AlarmResponseResult {
  const AlarmResponseResult({
    required this.response,
    required this.occurrence,
    required this.adjustedOccurrences,
    required this.alarmsSynchronized,
  });

  final AlarmResponse response;
  final ActivityOccurrence occurrence;
  final List<ActivityOccurrence> adjustedOccurrences;
  final bool alarmsSynchronized;

  int get displacedCount =>
      adjustedOccurrences.where((item) => item.id != occurrence.id).length;
}

final class AlarmResponseService {
  const AlarmResponseService({
    required this._occurrences,
    required this._events,
    required this._alarms,
    required this._planner,
    required this._alarmReconciler,
    required this._clock,
    required this._preferences,
  });

  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  final RoutinePlanner _planner;
  final AlarmReconciler _alarmReconciler;
  final Clock _clock;
  final UserPreferences _preferences;

  Future<AlarmResponseResult> respond({
    required String occurrenceId,
    required AlarmResponse response,
  }) async {
    final occurrence = await _occurrences.findById(occurrenceId);
    if (occurrence == null) {
      throw StateError('A ocorrência do alarme não foi encontrada.');
    }

    await _alarms.cancel(occurrenceId);
    return switch (response) {
      AlarmResponse.complete => _finish(
        occurrence,
        response,
        OccurrenceStatus.completed,
        ActivityEventType.completed,
      ),
      AlarmResponse.skipToday => _finish(
        occurrence,
        response,
        OccurrenceStatus.skipped,
        ActivityEventType.skipped,
      ),
      AlarmResponse.nowNot => _rescueRoutine(occurrence),
    };
  }

  Future<AlarmResponseResult> _finish(
    ActivityOccurrence occurrence,
    AlarmResponse response,
    OccurrenceStatus status,
    ActivityEventType eventType,
  ) async {
    final now = _clock.nowUtc();
    final updated = occurrence.copyWith(status: status);
    await _occurrences.update(updated);
    await _events.append(
      ActivityEvent(
        id: '${occurrence.id}:${eventType.name}:${now.microsecondsSinceEpoch}',
        occurrenceId: occurrence.id,
        type: eventType,
        occurredAtUtc: now,
      ),
    );
    var alarmsSynchronized = true;
    try {
      await _alarmReconciler.reconcile(_preferences);
    } catch (_) {
      alarmsSynchronized = false;
    }
    return AlarmResponseResult(
      response: response,
      occurrence: updated,
      adjustedOccurrences: const [],
      alarmsSynchronized: alarmsSynchronized,
    );
  }

  Future<AlarmResponseResult> _rescueRoutine(
    ActivityOccurrence occurrence,
  ) async {
    final now = _clock.nowUtc();
    final horizon = now.add(Duration(days: _preferences.scheduleHorizonDays));
    final existing = await _occurrences.findScheduledBetween(
      now.subtract(const Duration(days: 1)),
      horizon,
    );
    final plan = _planner.replanNowNot(
      occurrence: occurrence,
      existingOccurrences: existing,
      nowUtc: now,
      preferences: _preferences,
    );
    await _occurrences.saveAll(plan.adjustedOccurrences);
    await _events.append(
      ActivityEvent(
        id: '${occurrence.id}:nowNot:${now.microsecondsSinceEpoch}',
        occurrenceId: occurrence.id,
        type: ActivityEventType.nowNot,
        occurredAtUtc: now,
        previousStartUtc: occurrence.scheduledStartUtc,
        nextStartUtc: plan.rescheduled.scheduledStartUtc,
      ),
    );
    for (final adjusted in plan.adjustedOccurrences.where(
      (item) => item.id != occurrence.id,
    )) {
      final previous = existing
          .where((item) => item.id == adjusted.id)
          .firstOrNull;
      await _events.append(
        ActivityEvent(
          id: '${adjusted.id}:auto:${now.microsecondsSinceEpoch}',
          occurrenceId: adjusted.id,
          type: ActivityEventType.automaticallyRescheduled,
          occurredAtUtc: now,
          previousStartUtc: previous?.scheduledStartUtc,
          nextStartUtc: adjusted.scheduledStartUtc,
        ),
      );
    }

    var alarmsSynchronized = true;
    try {
      await _alarmReconciler.reconcile(_preferences);
    } catch (_) {
      alarmsSynchronized = false;
    }
    return AlarmResponseResult(
      response: AlarmResponse.nowNot,
      occurrence: plan.rescheduled,
      adjustedOccurrences: plan.adjustedOccurrences,
      alarmsSynchronized: alarmsSynchronized,
    );
  }
}

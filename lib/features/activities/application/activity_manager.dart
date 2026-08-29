import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../alarms/application/alarm_reconciler.dart';
import '../../alarms/domain/alarm_gateway.dart';
import '../../history/domain/activity_event.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/activity.dart';
import '../domain/activity_occurrence.dart';
import '../domain/activity_repositories.dart';
import '../domain/recurrence_rule.dart';
import 'occurrence_generator.dart';

final class ActivityEditDraft {
  const ActivityEditDraft({
    required this.title,
    required this.hour,
    required this.minute,
  });

  final String title;
  final int hour;
  final int minute;
}

final class ActivityMutationResult {
  const ActivityMutationResult({
    required this.activity,
    required this.affectedOccurrences,
    required this.generatedOccurrences,
    required this.alarmsSynchronized,
  });

  final Activity activity;
  final int affectedOccurrences;
  final int generatedOccurrences;
  final bool alarmsSynchronized;
}

final class ActivityManager {
  const ActivityManager({
    required ActivityRepository activities,
    required OccurrenceRepository occurrences,
    required ActivityEventRepository events,
    required AlarmGateway alarms,
    required AlarmReconciler alarmReconciler,
    required TimeZoneService timeZone,
    required Clock clock,
    required UserPreferences preferences,
  }) : this._(
         activities,
         occurrences,
         events,
         alarms,
         alarmReconciler,
         timeZone,
         clock,
         preferences,
       );

  const ActivityManager._(
    this._activities,
    this._occurrences,
    this._events,
    this._alarms,
    this._alarmReconciler,
    this._timeZone,
    this._clock,
    this._preferences,
  );

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final ActivityEventRepository _events;
  final AlarmGateway _alarms;
  final AlarmReconciler _alarmReconciler;
  final TimeZoneService _timeZone;
  final Clock _clock;
  final UserPreferences _preferences;

  Future<ActivityMutationResult> edit({
    required ActivityOccurrence selectedOccurrence,
    required ActivityEditDraft draft,
  }) async {
    _validateDraft(draft);
    final activity = await _requireActiveActivity(
      selectedOccurrence.activityId,
    );
    final now = _clock.nowUtc();
    final recurrence = _withTime(
      activity.recurrence,
      selectedOccurrence,
      draft.hour,
      draft.minute,
    );
    final updated = activity.copyWith(
      title: draft.title,
      recurrence: recurrence,
      updatedAtUtc: now,
    );
    final pending = await _occurrences.findPendingForActivity(activity.id);
    final cancelled = [
      for (final occurrence in pending)
        occurrence.copyWith(status: OccurrenceStatus.cancelled),
    ];
    final generated = OccurrenceGenerator(_timeZone).generate(
      activity: updated,
      fromUtc: now,
      untilUtc: now.add(Duration(days: _preferences.scheduleHorizonDays)),
    );

    if (generated.isEmpty && recurrence is OneOffRecurrence) {
      throw ArgumentError('Escolha um horário que ainda não passou.');
    }

    await _activities.save(updated);
    await _occurrences.saveAll([...cancelled, ...generated]);
    final nextStart = _nextStartForSelectedDay(selectedOccurrence, generated);
    await _events.append(
      ActivityEvent(
        id: '${selectedOccurrence.id}:edited:${now.microsecondsSinceEpoch}',
        occurrenceId: selectedOccurrence.id,
        type: ActivityEventType.edited,
        occurredAtUtc: now,
        previousStartUtc: selectedOccurrence.scheduledStartUtc,
        nextStartUtc: nextStart,
      ),
    );
    final alarmsSynchronized = await _synchronizeAlarms(pending);

    return ActivityMutationResult(
      activity: updated,
      affectedOccurrences: pending.length,
      generatedOccurrences: generated.length,
      alarmsSynchronized: alarmsSynchronized,
    );
  }

  Future<ActivityMutationResult> cancel({
    required ActivityOccurrence selectedOccurrence,
  }) async {
    final activity = await _requireActiveActivity(
      selectedOccurrence.activityId,
    );
    final now = _clock.nowUtc();
    final cancelledActivity = activity.copyWith(
      isActive: false,
      updatedAtUtc: now,
    );
    final pending = await _occurrences.findPendingForActivity(activity.id);
    final cancelled = [
      for (final occurrence in pending)
        occurrence.copyWith(status: OccurrenceStatus.cancelled),
    ];

    await _activities.save(cancelledActivity);
    if (cancelled.isNotEmpty) {
      await _occurrences.saveAll(cancelled);
    }
    await _events.append(
      ActivityEvent(
        id: '${selectedOccurrence.id}:cancelled:${now.microsecondsSinceEpoch}',
        occurrenceId: selectedOccurrence.id,
        type: ActivityEventType.cancelled,
        occurredAtUtc: now,
        previousStartUtc: selectedOccurrence.scheduledStartUtc,
      ),
    );
    final alarmsSynchronized = await _synchronizeAlarms(pending);

    return ActivityMutationResult(
      activity: cancelledActivity,
      affectedOccurrences: pending.length,
      generatedOccurrences: 0,
      alarmsSynchronized: alarmsSynchronized,
    );
  }

  Future<Activity> _requireActiveActivity(String activityId) async {
    final activity = await _activities.findById(activityId);
    if (activity == null) {
      throw StateError('Atividade não encontrada.');
    }
    if (!activity.isActive) {
      throw StateError('Esta atividade já foi cancelada.');
    }
    return activity;
  }

  RecurrenceRule _withTime(
    RecurrenceRule recurrence,
    ActivityOccurrence selectedOccurrence,
    int hour,
    int minute,
  ) {
    return switch (recurrence) {
      OneOffRecurrence() => OneOffRecurrence(
        _timeZone.localComponentsToUtc(
          DateTime(
            _timeZone.toLocal(selectedOccurrence.scheduledStartUtc).year,
            _timeZone.toLocal(selectedOccurrence.scheduledStartUtc).month,
            _timeZone.toLocal(selectedOccurrence.scheduledStartUtc).day,
            hour,
            minute,
          ),
        ),
      ),
      WeeklyRecurrence recurrence => WeeklyRecurrence(
        weekdays: recurrence.weekdays,
        hour: hour,
        minute: minute,
      ),
    };
  }

  DateTime? _nextStartForSelectedDay(
    ActivityOccurrence selectedOccurrence,
    List<ActivityOccurrence> generated,
  ) {
    final selected = _timeZone.toLocal(selectedOccurrence.scheduledStartUtc);
    for (final occurrence in generated) {
      final candidate = _timeZone.toLocal(occurrence.scheduledStartUtc);
      if (candidate.year == selected.year &&
          candidate.month == selected.month &&
          candidate.day == selected.day) {
        return occurrence.scheduledStartUtc;
      }
    }
    return generated.isEmpty ? null : generated.first.scheduledStartUtc;
  }

  Future<bool> _synchronizeAlarms(
    List<ActivityOccurrence> previousOccurrences,
  ) async {
    try {
      for (final occurrence in previousOccurrences) {
        await _alarms.cancel(occurrence.id);
      }
      await _alarmReconciler.reconcile(_preferences);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _validateDraft(ActivityEditDraft draft) {
    if (draft.title.trim().isEmpty) {
      throw ArgumentError('Digite o nome da atividade.');
    }
    if (draft.hour < 0 || draft.hour > 23) {
      throw ArgumentError.value(draft.hour, 'hour', 'Hora inválida.');
    }
    if (draft.minute < 0 || draft.minute > 59) {
      throw ArgumentError.value(draft.minute, 'minute', 'Minuto inválido.');
    }
  }
}

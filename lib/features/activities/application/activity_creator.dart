import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../alarms/application/alarm_reconciler.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/activity.dart';
import '../domain/activity_repositories.dart';
import '../domain/recurrence_rule.dart';
import 'occurrence_generator.dart';

final class ActivityDraft {
  const ActivityDraft({
    required this.title,
    required this.estimatedDuration,
    required this.priority,
    required this.recurrence,
    this.notes = '',
    this.preparationLead,
  });

  final String title;
  final String notes;
  final Duration estimatedDuration;
  final ActivityPriority priority;
  final RecurrenceRule recurrence;
  final Duration? preparationLead;
}

final class ActivityCreationResult {
  const ActivityCreationResult({
    required this.activity,
    required this.generatedOccurrences,
    required this.alarmsSynchronized,
  });

  final Activity activity;
  final int generatedOccurrences;
  final bool alarmsSynchronized;
}

final class ActivityCreator {
  const ActivityCreator({
    required this._activities,
    required this._occurrences,
    required this._timeZone,
    required this._alarmReconciler,
    required this._clock,
    required this._preferences,
  });

  final ActivityRepository _activities;
  final OccurrenceRepository _occurrences;
  final TimeZoneService _timeZone;
  final AlarmReconciler _alarmReconciler;
  final Clock _clock;
  final UserPreferences _preferences;

  Future<ActivityCreationResult> create(ActivityDraft draft) async {
    final now = _clock.nowUtc();
    final activity = Activity(
      id: 'activity-${now.microsecondsSinceEpoch}',
      title: draft.title,
      notes: draft.notes,
      estimatedDuration: draft.estimatedDuration,
      priority: draft.priority,
      recurrence: draft.recurrence,
      preparationLead: draft.preparationLead,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    final generated = OccurrenceGenerator(_timeZone).generate(
      activity: activity,
      fromUtc: now,
      untilUtc: now.add(Duration(days: _preferences.scheduleHorizonDays)),
    );

    await _activities.save(activity);
    await _occurrences.saveAll(generated);

    var alarmsSynchronized = true;
    try {
      await _alarmReconciler.reconcile(_preferences);
    } catch (_) {
      alarmsSynchronized = false;
    }

    return ActivityCreationResult(
      activity: activity,
      generatedOccurrences: generated.length,
      alarmsSynchronized: alarmsSynchronized,
    );
  }
}

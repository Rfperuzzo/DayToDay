import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../settings/domain/user_preferences.dart';
import '../domain/activity.dart';
import '../domain/activity_repositories.dart';
import 'occurrence_generator.dart';

final class OccurrenceHorizonMaintainer {
  factory OccurrenceHorizonMaintainer({
    required OccurrenceRepository occurrences,
    required TimeZoneService timeZone,
    required Clock clock,
  }) => OccurrenceHorizonMaintainer._(occurrences, timeZone, clock);

  OccurrenceHorizonMaintainer._(this._occurrences, this._timeZone, this._clock);

  final OccurrenceRepository _occurrences;
  final TimeZoneService _timeZone;
  final Clock _clock;
  final Map<String, Future<int>> _inFlight = {};

  Future<int> ensureRollingHorizon({
    required Iterable<Activity> activities,
    required UserPreferences preferences,
  }) {
    final fromUtc = _clock.nowUtc();
    final untilUtc = fromUtc.add(
      Duration(days: preferences.scheduleHorizonDays),
    );
    return _ensure(
      key: 'rolling:${_dayKey(_timeZone.toLocal(fromUtc))}',
      activities: activities,
      fromUtc: fromUtc,
      untilUtc: untilUtc,
    );
  }

  Future<int> ensureMonth({
    required Iterable<Activity> activities,
    required DateTime localMonth,
  }) {
    final monthStart = DateTime(localMonth.year, localMonth.month);
    final nextMonth = DateTime(localMonth.year, localMonth.month + 1);
    final nowUtc = _clock.nowUtc();
    final todayLocal = _timeZone.toLocal(nowUtc);
    final todayStart = DateTime(
      todayLocal.year,
      todayLocal.month,
      todayLocal.day,
    );
    if (!nextMonth.isAfter(todayStart)) {
      return Future.value(0);
    }
    final monthStartUtc = _timeZone.localComponentsToUtc(monthStart);
    final fromUtc = monthStart.isBefore(todayStart) ? nowUtc : monthStartUtc;
    return _ensure(
      key: 'month:${_monthKey(monthStart)}',
      activities: activities,
      fromUtc: fromUtc,
      untilUtc: _timeZone.localComponentsToUtc(nextMonth),
    );
  }

  Future<int> _ensure({
    required String key,
    required Iterable<Activity> activities,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) {
    final running = _inFlight[key];
    if (running != null) {
      return running;
    }
    late final Future<int> future;
    future =
        _materialize(
          activities: activities,
          fromUtc: fromUtc,
          untilUtc: untilUtc,
        ).whenComplete(() {
          if (identical(_inFlight[key], future)) {
            _inFlight.remove(key);
          }
        });
    _inFlight[key] = future;
    return future;
  }

  Future<int> _materialize({
    required Iterable<Activity> activities,
    required DateTime fromUtc,
    required DateTime untilUtc,
  }) async {
    final generator = OccurrenceGenerator(_timeZone);
    final generated = [
      for (final activity in activities)
        if (activity.isActive && activity.createdAtUtc.isBefore(untilUtc))
          ...generator.generate(
            activity: activity,
            fromUtc: activity.createdAtUtc.isAfter(fromUtc)
                ? activity.createdAtUtc
                : fromUtc,
            untilUtc: untilUtc,
          ),
    ];
    return _occurrences.saveGenerated(generated);
  }
}

String _dayKey(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-'
    '${local.month.toString().padLeft(2, '0')}-'
    '${local.day.toString().padLeft(2, '0')}';

String _monthKey(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-'
    '${local.month.toString().padLeft(2, '0')}';

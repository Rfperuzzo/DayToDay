import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
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
    final local = _timeZone.toLocal(now);
    final dayStart = _timeZone.localComponentsToUtc(
      DateTime(local.year, local.month, local.day),
    );
    // Boundary blocks intersecting the window include a still-pending final alarm,
    // even when their start was yesterday. The repository retains legacy semantics.
    final desired = await _occurrences.findScheduledBetween(dayStart, until);
    desired.sort((a, b) => a.scheduledStartUtc.compareTo(b.scheduledStartUtc));
    final existing = {
      for (final item in await _alarms.scheduled()) item.alarmKey: item,
    };
    final legacyDays = <String>{};
    final requests = <AlarmRequest>[];
    final starts = <AlarmRequest>[];
    final ends = <AlarmRequest>[];
    for (final occurrence in desired) {
      final activity = await _activities.findById(occurrence.activityId);
      if (activity != null && !activity.isActive) continue;
      final title = activity?.title ?? 'Atividade do DayToDay';
      if (!occurrence.usesBoundaryAlarms || occurrence.isReminder) {
        final localDay = _timeZone.toLocal(occurrence.scheduledStartUtc);
        if (!occurrence.isReminder &&
            !legacyDays.add(
              '${localDay.year}-${localDay.month}-${localDay.day}',
            )) {
          continue;
        }
        if (occurrence.acknowledgedAtUtc != null) continue;
        if (occurrence.scheduledStartUtc.isBefore(now) &&
            !existing.containsKey(occurrence.id)) {
          continue;
        }
        requests.add(
          AlarmRequest(
            occurrenceId: occurrence.id,
            scheduledAtUtc: occurrence.scheduledStartUtc,
            estimatedDuration: occurrence.estimatedDuration,
            title: title,
            body: 'Pare o aviso ou marque como feito no DayToDay.',
          ),
        );
        continue;
      }
      if (occurrence.notifyAtStart &&
          occurrence.acknowledgedAtUtc == null &&
          (!occurrence.scheduledStartUtc.isBefore(now) ||
              existing.containsKey(occurrence.id))) {
        starts.add(
          AlarmRequest(
            occurrenceId: occurrence.id,
            scheduledAtUtc: occurrence.scheduledStartUtc,
            estimatedDuration: occurrence.estimatedDuration,
            title: title,
            body: 'Hora de começar. Parar o aviso não conclui a atividade.',
          ),
        );
      }
      if (occurrence.notifyAtEnd &&
          occurrence.endAcknowledgedAtUtc == null &&
          (!occurrence.scheduledEndUtc.isBefore(now) ||
              existing.containsKey(AlarmIdentity.endKey(occurrence.id)))) {
        ends.add(
          AlarmRequest(
            occurrenceId: occurrence.id,
            phase: AlarmPhase.end,
            scheduledAtUtc: occurrence.scheduledEndUtc,
            estimatedDuration: occurrence.estimatedDuration,
            title: title,
            body:
                'Seu período reservado terminou. A conclusão é feita por você.',
          ),
        );
      }
    }
    // Non-overlapping time blocks have at most one end/start pair at an instant.
    // Only enabled, unacknowledged endpoints participate in a transition.
    final consumedEnds = <String>{};
    for (final start in starts) {
      final end = ends
          .where(
            (e) =>
                e.occurrenceId != start.occurrenceId &&
                e.scheduledAtUtc == start.scheduledAtUtc &&
                !consumedEnds.contains(e.alarmKey),
          )
          .firstOrNull;
      if (end == null) {
        requests.add(start);
        continue;
      }
      consumedEnds.add(end.alarmKey);
      requests.add(
        AlarmRequest(
          occurrenceId: start.occurrenceId,
          phase: AlarmPhase.transition,
          previousOccurrenceId: end.occurrenceId,
          scheduledAtUtc: start.scheduledAtUtc,
          estimatedDuration: start.estimatedDuration,
          title: '${end.title} → ${start.title}',
          body:
              'Hora de trocar. Termina: ${end.title}. Começa: ${start.title}.',
        ),
      );
    }
    requests.addAll(ends.where((e) => !consumedEnds.contains(e.alarmKey)));
    requests.sort((a, b) {
      final time = a.scheduledAtUtc.compareTo(b.scheduledAtUtc);
      return time != 0 ? time : a.alarmKey.compareTo(b.alarmKey);
    });
    final limited = requests.take(preferences.maxPendingAlarms).toList();
    final seen = <int, String>{};
    for (final request in limited) {
      final id = NativeAlarmId.fromOccurrenceId(request.alarmKey);
      if (seen.containsKey(id) && seen[id] != request.alarmKey) {
        throw StateError('Colisão de identificador de alarme.');
      }
      seen[id] = request.alarmKey;
    }
    final desiredKeys = limited.map((r) => r.alarmKey).toSet();
    for (final stale in existing.keys.where(
      (key) => !desiredKeys.contains(key),
    )) {
      await _alarms.cancel(stale);
    }
    for (final request in limited) {
      // Never replay an overdue alarm; preserve an already-ringing/retrying one.
      if (request.scheduledAtUtc.isBefore(now)) continue;
      final binding = existing[request.alarmKey];
      if (binding != null &&
          binding.scheduledAtUtc == request.scheduledAtUtc &&
          binding.phase == request.phase &&
          binding.previousOccurrenceId == request.previousOccurrenceId &&
          (binding.title == null || binding.title == request.title) &&
          (binding.body == null || binding.body == request.body)) {
        continue;
      }
      await _alarms.schedule(request);
    }
  }
}

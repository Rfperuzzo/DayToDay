import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_andriele/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_andriele/features/settings/domain/user_preferences.dart';

void main() {
  const planner = PriorityRoutinePlanner(_UtcTimeZone());
  const preferences = UserPreferences();

  test('reposiciona no próximo múltiplo de cinco minutos', () {
    final plan = planner.replanNowNot(
      occurrence: _occurrence('alvo', 10, priority: ActivityPriority.normal),
      existingOccurrences: const [],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 2, 20),
      preferences: preferences,
    );

    expect(
      plan.rescheduled.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 10, 5),
    );
    expect(plan.rescheduled.attempt, 1);
  });

  test('atividade menos prioritária espera a atividade importante', () {
    final important = _occurrence(
      'importante',
      10,
      minute: 5,
      durationMinutes: 60,
      priority: ActivityPriority.high,
    );

    final plan = planner.replanNowNot(
      occurrence: _occurrence(
        'alvo',
        10,
        durationMinutes: 30,
        priority: ActivityPriority.normal,
      ),
      existingOccurrences: [important],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 2),
      preferences: preferences,
    );

    expect(
      plan.rescheduled.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 5),
    );
  });

  test('atividade importante desloca conflito menos prioritário', () {
    final lowerPriority = _occurrence(
      'flexivel',
      10,
      minute: 15,
      durationMinutes: 30,
      priority: ActivityPriority.low,
    );

    final plan = planner.replanNowNot(
      occurrence: _occurrence(
        'alvo',
        10,
        durationMinutes: 60,
        priority: ActivityPriority.high,
      ),
      existingOccurrences: [lowerPriority],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 2),
      preferences: preferences,
    );

    expect(
      plan.rescheduled.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 10, 5),
    );
    final displaced = plan.adjustedOccurrences.singleWhere(
      (item) => item.id == 'flexivel',
    );
    expect(displaced.scheduledStartUtc, DateTime.utc(2026, 8, 31, 11, 5));
  });

  test('quarta tentativa começa no dia seguinte', () {
    final plan = planner.replanNowNot(
      occurrence: _occurrence(
        'alvo',
        21,
        attempt: 3,
        priority: ActivityPriority.normal,
      ),
      existingOccurrences: const [],
      nowUtc: DateTime.utc(2026, 8, 31, 21, 30),
      preferences: preferences,
    );

    expect(plan.rescheduled.scheduledStartUtc, DateTime.utc(2026, 9, 1, 7));
    expect(plan.rescheduled.attempt, 4);
  });

  test('atividade que não cabe hoje passa para amanhã', () {
    final plan = planner.replanNowNot(
      occurrence: _occurrence(
        'alvo',
        21,
        durationMinutes: 90,
        priority: ActivityPriority.normal,
      ),
      existingOccurrences: const [],
      nowUtc: DateTime.utc(2026, 8, 31, 21, 30),
      preferences: preferences,
    );

    expect(plan.rescheduled.scheduledStartUtc, DateTime.utc(2026, 9, 1, 7));
  });

  test('tarefa perdida mais importante ocupa o lugar da próxima', () {
    final plan = planner.replanMissed(
      occurrence: _occurrence(
        'perdida',
        10,
        durationMinutes: 30,
        priority: ActivityPriority.high,
      ),
      followingOccurrences: [
        _occurrence(
          'seguinte',
          11,
          durationMinutes: 20,
          priority: ActivityPriority.low,
        ),
      ],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 30),
    );

    expect(plan.rescheduled.scheduledStartUtc, DateTime.utc(2026, 8, 31, 11));
    expect(
      plan.adjustedOccurrences
          .singleWhere((item) => item.id == 'seguinte')
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 40),
    );
  });

  test('cascata compara novamente a tarefa que perdeu o lugar', () {
    final plan = planner.replanMissed(
      occurrence: _occurrence(
        'perdida',
        10,
        durationMinutes: 30,
        priority: ActivityPriority.high,
      ),
      followingOccurrences: [
        _occurrence(
          'normal',
          11,
          durationMinutes: 30,
          priority: ActivityPriority.normal,
        ),
        _occurrence(
          'flexivel',
          11,
          minute: 30,
          durationMinutes: 20,
          priority: ActivityPriority.low,
        ),
      ],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 30),
    );

    expect(
      plan.adjustedOccurrences
          .singleWhere((item) => item.id == 'perdida')
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11),
    );
    expect(
      plan.adjustedOccurrences
          .singleWhere((item) => item.id == 'normal')
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 30),
    );
    expect(
      plan.adjustedOccurrences
          .singleWhere((item) => item.id == 'flexivel')
          .scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 12, 10),
    );
  });

  test('sem próxima tarefa reagenda a perdida dez minutos à frente', () {
    final plan = planner.replanMissed(
      occurrence: _occurrence('perdida', 10, priority: ActivityPriority.normal),
      followingOccurrences: const [],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 30),
    );

    expect(
      plan.rescheduled.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 10, 40),
    );
    expect(plan.rescheduled.attempt, 1);
  });

  test('tarefa perdida não toma o lugar de uma mais importante', () {
    final plan = planner.replanMissed(
      occurrence: _occurrence('perdida', 10, priority: ActivityPriority.normal),
      followingOccurrences: [
        _occurrence(
          'prioridade',
          11,
          durationMinutes: 30,
          priority: ActivityPriority.high,
        ),
      ],
      nowUtc: DateTime.utc(2026, 8, 31, 10, 30),
    );

    expect(
      plan.rescheduled.scheduledStartUtc,
      DateTime.utc(2026, 8, 31, 11, 40),
    );
    expect(
      plan.adjustedOccurrences.any((item) => item.id == 'prioridade'),
      isFalse,
    );
  });
}

ActivityOccurrence _occurrence(
  String id,
  int hour, {
  int minute = 0,
  int durationMinutes = 30,
  int attempt = 0,
  required ActivityPriority priority,
}) {
  final start = DateTime.utc(2026, 8, 31, hour, minute);
  return ActivityOccurrence(
    id: id,
    activityId: 'atividade-$id',
    originalStartUtc: start,
    scheduledStartUtc: start,
    estimatedDuration: Duration(minutes: durationMinutes),
    priority: priority,
    status: OccurrenceStatus.scheduled,
    attempt: attempt,
  );
}

final class _UtcTimeZone implements TimeZoneService {
  const _UtcTimeZone();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) {
    return DateTime.utc(
      localComponents.year,
      localComponents.month,
      localComponents.day,
      localComponents.hour,
      localComponents.minute,
    );
  }

  @override
  DateTime toLocal(DateTime utc) => utc.toUtc();
}

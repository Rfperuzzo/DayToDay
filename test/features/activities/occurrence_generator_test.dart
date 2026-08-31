import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/application/occurrence_generator.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/recurrence_rule.dart';

void main() {
  const timeZone = _UtcTimeZone();
  const generator = OccurrenceGenerator(timeZone);

  Activity activityWith(RecurrenceRule recurrence, {bool isActive = true}) {
    return Activity(
      id: 'atividade-1',
      title: 'Estudar',
      estimatedDuration: const Duration(hours: 1),
      priority: ActivityPriority.normal,
      recurrence: recurrence,
      createdAtUtc: DateTime.utc(2026, 8, 1),
      updatedAtUtc: DateTime.utc(2026, 8, 1),
      isActive: isActive,
    );
  }

  test('gera uma ocorrência única dentro do horizonte', () {
    final scheduledAt = DateTime.utc(2026, 8, 31, 14);

    final result = generator.generate(
      activity: activityWith(OneOffRecurrence(scheduledAt)),
      fromUtc: DateTime.utc(2026, 8, 29),
      untilUtc: DateTime.utc(2026, 9, 2),
    );

    expect(result, hasLength(1));
    expect(result.single.scheduledStartUtc, scheduledAt);
    expect(result.single.originalStartUtc, scheduledAt);
  });

  test('não recria uma ocorrência única fora do horizonte', () {
    final result = generator.generate(
      activity: activityWith(OneOffRecurrence(DateTime.utc(2026, 8, 28))),
      fromUtc: DateTime.utc(2026, 8, 29),
      untilUtc: DateTime.utc(2026, 9, 2),
    );

    expect(result, isEmpty);
  });

  test('gera somente os dias selecionados na recorrência semanal', () {
    final result = generator.generate(
      activity: activityWith(
        WeeklyRecurrence(
          weekdays: const {DateTime.monday, DateTime.wednesday},
          hour: 9,
          minute: 30,
        ),
      ),
      fromUtc: DateTime.utc(2026, 8, 31),
      untilUtc: DateTime.utc(2026, 9, 7),
    );

    expect(result.map((occurrence) => occurrence.scheduledStartUtc), [
      DateTime.utc(2026, 8, 31, 9, 30),
      DateTime.utc(2026, 9, 2, 9, 30),
    ]);
  });

  test('atividade inativa não gera ocorrências', () {
    final result = generator.generate(
      activity: activityWith(
        WeeklyRecurrence.daily(hour: 8, minute: 0),
        isActive: false,
      ),
      fromUtc: DateTime.utc(2026, 8, 29),
      untilUtc: DateTime.utc(2026, 8, 31),
    );

    expect(result, isEmpty);
  });
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

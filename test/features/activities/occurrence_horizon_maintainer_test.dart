import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/occurrence_horizon_maintainer.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

void main() {
  late _MemoryOccurrences occurrences;
  late OccurrenceHorizonMaintainer maintainer;

  setUp(() {
    occurrences = _MemoryOccurrences();
    maintainer = OccurrenceHorizonMaintainer(
      occurrences: occurrences,
      timeZone: const _UtcTimeZone(),
      clock: const _FixedClock(),
    );
  });

  test('prepara mês futuro inteiro sem duplicar ocorrências', () async {
    final activity = _dailyActivity();
    final oneOff = Activity(
      id: 'compromisso-unico',
      title: 'Compromisso único',
      estimatedDuration: const Duration(minutes: 20),
      priority: ActivityPriority.high,
      recurrence: OneOffRecurrence(DateTime.utc(2026, 12, 15, 14)),
      createdAtUtc: DateTime.utc(2026, 8, 1),
      updatedAtUtc: DateTime.utc(2026, 8, 1),
    );

    expect(
      await maintainer.ensureMonth(
        activities: [activity, oneOff],
        localMonth: DateTime(2026, 12),
      ),
      32,
    );
    expect(occurrences.values, hasLength(32));
    expect(
      occurrences.values.first.scheduledStartUtc,
      DateTime.utc(2026, 12, 1, 9),
    );

    expect(
      await maintainer.ensureMonth(
        activities: [activity, oneOff],
        localMonth: DateTime(2026, 12),
      ),
      0,
    );
    expect(occurrences.values, hasLength(32));
  });

  test(
    'não fabrica histórico anterior e limita o mês atual ao futuro',
    () async {
      final activity = _dailyActivity();

      expect(
        await maintainer.ensureMonth(
          activities: [activity],
          localMonth: DateTime(2026, 7),
        ),
        0,
      );
      expect(occurrences.saveGeneratedCalls, 0);

      expect(
        await maintainer.ensureMonth(
          activities: [activity],
          localMonth: DateTime(2026, 8),
        ),
        2,
      );
      expect(occurrences.values.map((item) => item.scheduledStartUtc), [
        DateTime.utc(2026, 8, 30, 9),
        DateTime.utc(2026, 8, 31, 9),
      ]);
    },
  );

  test('deduplica preparações simultâneas do mesmo mês', () async {
    final first = maintainer.ensureMonth(
      activities: [_dailyActivity()],
      localMonth: DateTime(2027, 1),
    );
    final second = maintainer.ensureMonth(
      activities: [_dailyActivity()],
      localMonth: DateTime(2027, 1),
    );

    expect(identical(first, second), isTrue);
    expect(await first, 31);
    expect(await second, 31);
    expect(occurrences.saveGeneratedCalls, 1);
  });

  test('horizonte móvel respeita a quantidade de dias configurada', () async {
    expect(
      await maintainer.ensureRollingHorizon(
        activities: [_dailyActivity()],
        preferences: const UserPreferences(scheduleHorizonDays: 3),
      ),
      3,
    );
    expect(occurrences.values.map((item) => item.scheduledStartUtc), [
      DateTime.utc(2026, 8, 30, 9),
      DateTime.utc(2026, 8, 31, 9),
      DateTime.utc(2026, 9, 1, 9),
    ]);
  });
}

Activity _dailyActivity() => Activity(
  id: 'rotina-diaria',
  title: 'Rotina diária',
  estimatedDuration: const Duration(minutes: 30),
  priority: ActivityPriority.normal,
  recurrence: WeeklyRecurrence.daily(hour: 9, minute: 0),
  createdAtUtc: DateTime.utc(2026, 8, 1),
  updatedAtUtc: DateTime.utc(2026, 8, 1),
);

final class _MemoryOccurrences implements OccurrenceRepository {
  final values = <ActivityOccurrence>[];
  int saveGeneratedCalls = 0;

  @override
  Future<ActivityOccurrence?> findById(String id) async =>
      values.where((item) => item.id == id).firstOrNull;

  @override
  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId) async =>
      values
          .where(
            (item) => NativeAlarmId.fromOccurrenceId(item.id) == nativeAlarmId,
          )
          .firstOrNull;

  @override
  Future<List<ActivityOccurrence>> findPendingForActivity(
    String activityId,
  ) async => values.where((item) => item.activityId == activityId).toList();

  @override
  Future<List<ActivityOccurrence>> findScheduledBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) async => values
      .where(
        (item) =>
            item.status == OccurrenceStatus.scheduled &&
            !item.scheduledStartUtc.isBefore(startUtc) &&
            item.scheduledStartUtc.isBefore(endUtc),
      )
      .toList();

  @override
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences) async {
    for (final occurrence in occurrences) {
      await update(occurrence);
    }
  }

  @override
  Future<int> saveGenerated(Iterable<ActivityOccurrence> occurrences) async {
    saveGeneratedCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 1));
    var saved = 0;
    for (final occurrence in occurrences) {
      final existing = await findById(occurrence.id);
      if (existing == null || existing.status == OccurrenceStatus.cancelled) {
        await update(occurrence);
        saved++;
      }
    }
    return saved;
  }

  @override
  Future<void> update(ActivityOccurrence occurrence) async {
    values
      ..removeWhere((item) => item.id == occurrence.id)
      ..add(occurrence);
    values.sort(
      (left, right) =>
          left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
    );
  }

  @override
  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) => Stream.value(values);
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 8, 29, 10);
}

final class _UtcTimeZone implements TimeZoneService {
  const _UtcTimeZone();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) => DateTime.utc(
    localComponents.year,
    localComponents.month,
    localComponents.day,
    localComponents.hour,
    localComponents.minute,
  );

  @override
  DateTime toLocal(DateTime utc) => utc.toUtc();
}

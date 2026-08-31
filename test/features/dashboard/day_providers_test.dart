import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_andriele/app/app_dependencies.dart';
import 'package:rotina_andriele/core/time/time_zone_service.dart';
import 'package:rotina_andriele/features/activities/domain/activity.dart';
import 'package:rotina_andriele/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_andriele/features/activities/domain/activity_repositories.dart';
import 'package:rotina_andriele/features/alarms/infrastructure/native_alarm_id.dart';
import 'package:rotina_andriele/features/dashboard/application/day_providers.dart';

void main() {
  test('selecionar data consulta somente as tarefas daquele dia', () async {
    final august = _occurrence('agosto', DateTime.utc(2026, 8, 31, 9));
    final september = _occurrence('setembro', DateTime.utc(2026, 9, 1, 10));
    final repository = _MemoryOccurrences([august, september]);
    final container = ProviderContainer(
      overrides: [
        occurrenceRepositoryProvider.overrideWithValue(repository),
        timeZoneServiceProvider.overrideWithValue(const _UtcTimeZone()),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedDayProvider.notifier).select(DateTime(2026, 9, 1));
    final selected = container.read(selectedDayProvider);
    final provider = dayOccurrencesProvider(selected);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final result = await container.read(provider.future);

    expect(selected, DateTime(2026, 9, 1));
    expect(result.map((item) => item.id), ['setembro']);
  });
}

ActivityOccurrence _occurrence(String id, DateTime scheduledAtUtc) =>
    ActivityOccurrence(
      id: id,
      activityId: 'atividade',
      originalStartUtc: scheduledAtUtc,
      scheduledStartUtc: scheduledAtUtc,
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      status: OccurrenceStatus.scheduled,
    );

final class _MemoryOccurrences implements OccurrenceRepository {
  const _MemoryOccurrences(this.values);

  final List<ActivityOccurrence> values;

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
            !item.scheduledStartUtc.isBefore(startUtc) &&
            item.scheduledStartUtc.isBefore(endUtc),
      )
      .toList();

  @override
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences) async {}

  @override
  Future<int> saveGenerated(Iterable<ActivityOccurrence> occurrences) async =>
      0;

  @override
  Future<void> update(ActivityOccurrence occurrence) async {}

  @override
  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  ) => Stream.value(
    values
        .where(
          (item) =>
              !item.scheduledStartUtc.isBefore(startUtc) &&
              item.scheduledStartUtc.isBefore(endUtc),
        )
        .toList(),
  );
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

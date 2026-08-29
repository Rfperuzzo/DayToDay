import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/subtask.dart';

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

final activeActivitiesProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).watchActive(),
);

final allActivitiesProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(activityRepositoryProvider).watchAll(),
);

final subtasksProvider = StreamProvider.family<List<Subtask>, String>(
  (ref, activityId) =>
      ref.watch(subtaskRepositoryProvider).watchForActivity(activityId),
);

final dayOccurrencesProvider =
    StreamProvider.family<List<ActivityOccurrence>, DateTime>((ref, day) {
      final normalizedDay = dateOnly(day);
      final timeZone = ref.watch(timeZoneServiceProvider);
      final startUtc = timeZone.localComponentsToUtc(normalizedDay);
      final endUtc = timeZone.localComponentsToUtc(
        normalizedDay.add(const Duration(days: 1)),
      );
      return ref
          .watch(occurrenceRepositoryProvider)
          .watchBetween(startUtc, endUtc);
    });

final class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime day) => state = dateOnly(day);
}

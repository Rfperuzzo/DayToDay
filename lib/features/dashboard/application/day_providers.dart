import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/domain/subtask.dart';
import '../../home_widget/domain/day_widget_gateway.dart';

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

final dayWidgetOpenRequestProvider =
    NotifierProvider<DayWidgetOpenRequestNotifier, DayWidgetOpenRequest?>(
      DayWidgetOpenRequestNotifier.new,
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

final widgetOccurrencesProvider = StreamProvider<List<ActivityOccurrence>>((
  ref,
) {
  final timeZone = ref.watch(timeZoneServiceProvider);
  final today = dateOnly(DateTime.now());
  final startUtc = timeZone.localComponentsToUtc(today);
  final endUtc = timeZone.localComponentsToUtc(
    today.add(const Duration(days: 7)),
  );
  return ref.watch(occurrenceRepositoryProvider).watchBetween(startUtc, endUtc);
});

final class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void select(DateTime day) => state = dateOnly(day);
}

final class DayWidgetOpenRequestNotifier
    extends Notifier<DayWidgetOpenRequest?> {
  @override
  DayWidgetOpenRequest? build() => null;

  void open(DayWidgetOpenRequest request) => state = request;

  DayWidgetOpenRequest? take() {
    final current = state;
    state = null;
    return current;
  }
}

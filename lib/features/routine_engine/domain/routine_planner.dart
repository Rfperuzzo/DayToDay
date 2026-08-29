import '../../activities/domain/activity_occurrence.dart';
import '../../settings/domain/user_preferences.dart';

final class RoutinePlan {
  const RoutinePlan({
    required this.rescheduled,
    required this.adjustedOccurrences,
  });

  final ActivityOccurrence rescheduled;
  final List<ActivityOccurrence> adjustedOccurrences;
}

abstract interface class RoutinePlanner {
  RoutinePlan replanNowNot({
    required ActivityOccurrence occurrence,
    required Iterable<ActivityOccurrence> existingOccurrences,
    required DateTime nowUtc,
    required UserPreferences preferences,
  });
}

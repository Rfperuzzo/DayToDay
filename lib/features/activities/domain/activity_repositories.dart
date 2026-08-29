import 'activity.dart';
import 'activity_occurrence.dart';

abstract interface class ActivityRepository {
  Future<void> save(Activity activity);

  Future<Activity?> findById(String id);

  Stream<List<Activity>> watchActive();
}

abstract interface class OccurrenceRepository {
  Future<void> saveAll(Iterable<ActivityOccurrence> occurrences);

  Future<void> update(ActivityOccurrence occurrence);

  Future<ActivityOccurrence?> findById(String id);

  Future<ActivityOccurrence?> findByNativeAlarmId(int nativeAlarmId);

  Future<List<ActivityOccurrence>> findScheduledBetween(
    DateTime startUtc,
    DateTime endUtc,
  );

  Stream<List<ActivityOccurrence>> watchBetween(
    DateTime startUtc,
    DateTime endUtc,
  );
}

import 'subtask.dart';

abstract interface class SubtaskRepository {
  Future<void> save(Subtask subtask);

  Future<void> delete(String subtaskId);

  Future<List<Subtask>> findForActivity(String activityId);

  Stream<List<Subtask>> watchForActivity(String activityId);
}

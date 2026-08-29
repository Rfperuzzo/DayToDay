import '../../../core/time/clock.dart';
import '../domain/subtask.dart';
import '../domain/subtask_repository.dart';

final class SubtaskManager {
  const SubtaskManager({
    required SubtaskRepository subtasks,
    required Clock clock,
  }) : this._(subtasks, clock);

  const SubtaskManager._(this._subtasks, this._clock);

  final SubtaskRepository _subtasks;
  final Clock _clock;

  Future<Subtask> add({
    required String activityId,
    required String title,
  }) async {
    final existing = await _subtasks.findForActivity(activityId);
    final now = _clock.nowUtc();
    final subtask = Subtask(
      id: '$activityId:subtask:${now.microsecondsSinceEpoch}',
      activityId: activityId,
      title: title,
      position: existing.length,
      createdAtUtc: now,
    );
    await _subtasks.save(subtask);
    return subtask;
  }

  Future<void> setCompleted(Subtask subtask, bool completed) async {
    if (subtask.isCompleted == completed) {
      return;
    }
    await _subtasks.save(
      completed ? subtask.complete(_clock.nowUtc()) : subtask.reopen(),
    );
  }

  Future<void> delete(Subtask subtask) => _subtasks.delete(subtask.id);
}

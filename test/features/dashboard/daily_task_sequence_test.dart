import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/dashboard/application/daily_task_sequence.dart';

void main() {
  test('somente a primeira tarefa pendente fica disponível', () {
    final first = _occurrence('primeira', 9);
    final second = _occurrence('segunda', 10);

    final available = DailyTaskSequence.firstAvailable([second, first]);

    expect(available, same(first));
    expect(
      DailyTaskSequence.isLocked(occurrence: first, available: available),
      isFalse,
    );
    expect(
      DailyTaskSequence.isLocked(occurrence: second, available: available),
      isTrue,
    );
  });

  test('conclusão antecipada libera imediatamente a próxima tarefa', () {
    final completedEarly = _occurrence(
      'primeira',
      9,
      status: OccurrenceStatus.completed,
    );
    final second = _occurrence('segunda', 10);

    final available = DailyTaskSequence.firstAvailable([
      completedEarly,
      second,
    ]);

    expect(available, same(second));
    expect(
      DailyTaskSequence.isLocked(occurrence: second, available: available),
      isFalse,
    );
  });
}

ActivityOccurrence _occurrence(
  String id,
  int hour, {
  OccurrenceStatus status = OccurrenceStatus.scheduled,
}) => ActivityOccurrence(
  id: id,
  activityId: 'activity-$id',
  originalStartUtc: DateTime.utc(2026, 8, 29, hour),
  scheduledStartUtc: DateTime.utc(2026, 8, 29, hour),
  estimatedDuration: const Duration(minutes: 45),
  priority: ActivityPriority.normal,
  status: status,
);

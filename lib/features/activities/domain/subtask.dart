final class Subtask {
  factory Subtask({
    required String id,
    required String activityId,
    required String title,
    required int position,
    required DateTime createdAtUtc,
    bool isCompleted = false,
    DateTime? completedAtUtc,
  }) {
    final normalizedId = id.trim();
    final normalizedActivityId = activityId.trim();
    final normalizedTitle = title.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador é obrigatório.');
    }
    if (normalizedActivityId.isEmpty) {
      throw ArgumentError.value(
        activityId,
        'activityId',
        'A atividade principal é obrigatória.',
      );
    }
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Digite a subtarefa.');
    }
    if (position < 0) {
      throw ArgumentError.value(position, 'position', 'Posição inválida.');
    }
    return Subtask._(
      id: normalizedId,
      activityId: normalizedActivityId,
      title: normalizedTitle,
      position: position,
      isCompleted: isCompleted,
      createdAtUtc: createdAtUtc.toUtc(),
      completedAtUtc: completedAtUtc?.toUtc(),
    );
  }

  const Subtask._({
    required this.id,
    required this.activityId,
    required this.title,
    required this.position,
    required this.isCompleted,
    required this.createdAtUtc,
    required this.completedAtUtc,
  });

  final String id;
  final String activityId;
  final String title;
  final int position;
  final bool isCompleted;
  final DateTime createdAtUtc;
  final DateTime? completedAtUtc;

  Subtask complete(DateTime completedAtUtc) => Subtask(
    id: id,
    activityId: activityId,
    title: title,
    position: position,
    isCompleted: true,
    createdAtUtc: createdAtUtc,
    completedAtUtc: completedAtUtc,
  );

  Subtask reopen() => Subtask(
    id: id,
    activityId: activityId,
    title: title,
    position: position,
    createdAtUtc: createdAtUtc,
  );
}

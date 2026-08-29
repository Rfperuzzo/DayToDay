import 'recurrence_rule.dart';

enum ActivityPriority { low, normal, high }

final class Activity {
  factory Activity({
    required String id,
    required String title,
    required Duration estimatedDuration,
    required ActivityPriority priority,
    required RecurrenceRule recurrence,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    String notes = '',
    Duration? preparationLead,
    bool isActive = true,
  }) {
    final normalizedId = id.trim();
    final normalizedTitle = title.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador é obrigatório.');
    }
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'O título é obrigatório.');
    }
    if (estimatedDuration <= Duration.zero) {
      throw ArgumentError.value(
        estimatedDuration,
        'estimatedDuration',
        'A duração deve ser positiva.',
      );
    }
    if (preparationLead != null && preparationLead < Duration.zero) {
      throw ArgumentError.value(
        preparationLead,
        'preparationLead',
        'O tempo de preparação não pode ser negativo.',
      );
    }
    return Activity._(
      id: normalizedId,
      title: normalizedTitle,
      notes: notes.trim(),
      estimatedDuration: estimatedDuration,
      priority: priority,
      recurrence: recurrence,
      preparationLead: preparationLead,
      isActive: isActive,
      createdAtUtc: createdAtUtc.toUtc(),
      updatedAtUtc: updatedAtUtc.toUtc(),
    );
  }

  const Activity._({
    required this.id,
    required this.title,
    required this.notes,
    required this.estimatedDuration,
    required this.priority,
    required this.recurrence,
    required this.preparationLead,
    required this.isActive,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String title;
  final String notes;
  final Duration estimatedDuration;
  final ActivityPriority priority;
  final RecurrenceRule recurrence;
  final Duration? preparationLead;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

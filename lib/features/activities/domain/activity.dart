import 'recurrence_rule.dart';

enum ActivityKind { reminder, timeBlock }

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
    ActivityKind kind = ActivityKind.timeBlock,
    String notes = '',
    Duration? preparationLead,
    bool isActive = true,
    bool notifyAtStart = true,
    bool notifyAtEnd = false,
    bool usesBoundaryAlarms = false,
  }) {
    final normalizedId = id.trim();
    final normalizedTitle = title.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador é obrigatório.');
    }
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'O título é obrigatório.');
    }
    if (kind == ActivityKind.timeBlock && estimatedDuration <= Duration.zero) {
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
      kind: kind,
      estimatedDuration: kind == ActivityKind.reminder
          ? Duration.zero
          : estimatedDuration,
      priority: priority,
      recurrence: recurrence,
      preparationLead: preparationLead,
      isActive: isActive,
      notifyAtStart: kind == ActivityKind.reminder ? true : notifyAtStart,
      notifyAtEnd: kind == ActivityKind.reminder ? false : notifyAtEnd,
      usesBoundaryAlarms: kind == ActivityKind.timeBlock && usesBoundaryAlarms,
      createdAtUtc: createdAtUtc.toUtc(),
      updatedAtUtc: updatedAtUtc.toUtc(),
    );
  }

  const Activity._({
    required this.kind,
    required this.id,
    required this.title,
    required this.notes,
    required this.estimatedDuration,
    required this.priority,
    required this.recurrence,
    required this.preparationLead,
    required this.isActive,
    required this.notifyAtStart,
    required this.notifyAtEnd,
    required this.usesBoundaryAlarms,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final ActivityKind kind;
  bool get isReminder => kind == ActivityKind.reminder;
  final String id;
  final String title;
  final String notes;
  final Duration estimatedDuration;
  final ActivityPriority priority;
  final RecurrenceRule recurrence;
  final Duration? preparationLead;
  final bool isActive;
  final bool notifyAtStart;
  final bool notifyAtEnd;
  final bool usesBoundaryAlarms;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  Activity copyWith({
    ActivityKind? kind,
    String? title,
    String? notes,
    Duration? estimatedDuration,
    ActivityPriority? priority,
    RecurrenceRule? recurrence,
    Duration? preparationLead,
    bool? isActive,
    bool? notifyAtStart,
    bool? notifyAtEnd,
    bool? usesBoundaryAlarms,
    DateTime? updatedAtUtc,
  }) {
    return Activity(
      kind: kind ?? this.kind,
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      preparationLead: preparationLead ?? this.preparationLead,
      isActive: isActive ?? this.isActive,
      notifyAtStart: notifyAtStart ?? this.notifyAtStart,
      notifyAtEnd: notifyAtEnd ?? this.notifyAtEnd,
      usesBoundaryAlarms: usesBoundaryAlarms ?? this.usesBoundaryAlarms,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }
}

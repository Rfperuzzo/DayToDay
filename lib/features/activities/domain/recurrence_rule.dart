sealed class RecurrenceRule {
  const RecurrenceRule();
}

final class OneOffRecurrence extends RecurrenceRule {
  OneOffRecurrence(DateTime scheduledAtUtc)
    : scheduledAtUtc = scheduledAtUtc.toUtc();

  final DateTime scheduledAtUtc;
}

final class WeeklyRecurrence extends RecurrenceRule {
  factory WeeklyRecurrence({
    required Set<int> weekdays,
    required int hour,
    required int minute,
  }) {
    if (weekdays.isEmpty || weekdays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Use os valores DateTime.monday a DateTime.sunday.',
      );
    }
    if (hour < 0 || hour > 23) {
      throw RangeError.range(hour, 0, 23, 'hour');
    }
    if (minute < 0 || minute > 59) {
      throw RangeError.range(minute, 0, 59, 'minute');
    }
    return WeeklyRecurrence._(Set.unmodifiable(weekdays), hour, minute);
  }

  factory WeeklyRecurrence.daily({required int hour, required int minute}) {
    return WeeklyRecurrence(
      weekdays: const {
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      },
      hour: hour,
      minute: minute,
    );
  }

  const WeeklyRecurrence._(this.weekdays, this.hour, this.minute);

  final Set<int> weekdays;
  final int hour;
  final int minute;
}

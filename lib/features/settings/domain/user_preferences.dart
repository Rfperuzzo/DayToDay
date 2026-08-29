final class UserPreferences {
  const UserPreferences({
    this.dayStartMinutes = 7 * 60,
    this.dayEndMinutes = 22 * 60,
    this.maxSameDayReplans = 3,
    this.scheduleHorizonDays = 30,
    this.maxPendingAlarms = 200,
  }) : assert(dayStartMinutes >= 0 && dayStartMinutes < 24 * 60),
       assert(dayEndMinutes > dayStartMinutes && dayEndMinutes <= 24 * 60),
       assert(maxSameDayReplans >= 0),
       assert(scheduleHorizonDays > 0),
       assert(maxPendingAlarms > 0);

  final int dayStartMinutes;
  final int dayEndMinutes;
  final int maxSameDayReplans;
  final int scheduleHorizonDays;
  final int maxPendingAlarms;
}

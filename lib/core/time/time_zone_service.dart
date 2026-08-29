abstract interface class TimeZoneService {
  DateTime toLocal(DateTime utc);

  DateTime localComponentsToUtc(DateTime localComponents);
}

final class DeviceTimeZoneService implements TimeZoneService {
  const DeviceTimeZoneService();

  @override
  DateTime toLocal(DateTime utc) => utc.toLocal();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) {
    return DateTime(
      localComponents.year,
      localComponents.month,
      localComponents.day,
      localComponents.hour,
      localComponents.minute,
      localComponents.second,
      localComponents.millisecond,
      localComponents.microsecond,
    ).toUtc();
  }
}

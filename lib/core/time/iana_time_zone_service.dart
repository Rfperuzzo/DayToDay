import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'time_zone_service.dart';

final class IanaTimeZoneService implements TimeZoneService {
  const IanaTimeZoneService._(this._location);

  final tz.Location _location;

  static Future<IanaTimeZoneService> create() async {
    tz_data.initializeTimeZones();
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    final location = tz.getLocation(deviceTimeZone.identifier);
    return IanaTimeZoneService._(location);
  }

  @override
  DateTime toLocal(DateTime utc) => tz.TZDateTime.from(utc.toUtc(), _location);

  @override
  DateTime localComponentsToUtc(DateTime localComponents) {
    return tz.TZDateTime(
      _location,
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

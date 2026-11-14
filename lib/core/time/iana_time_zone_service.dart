import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'time_zone_service.dart';

final class IanaTimeZoneService implements TimeZoneService {
  const IanaTimeZoneService._(this._location);

  final tz.Location _location;

  factory IanaTimeZoneService.fromIdentifier(String identifier) {
    tz_data.initializeTimeZones();
    // Common zero-offset identifiers are aliases omitted by some TZ databases.
    if (identifier == 'GMT' || identifier == 'UTC') {
      return IanaTimeZoneService._(tz.UTC);
    }
    return IanaTimeZoneService._(tz.getLocation(identifier));
  }

  static Future<IanaTimeZoneService> create() async {
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    return IanaTimeZoneService.fromIdentifier(deviceTimeZone.identifier);
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

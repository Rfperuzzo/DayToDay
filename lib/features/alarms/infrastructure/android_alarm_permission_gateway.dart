import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/alarm_permission_gateway.dart';

final class AndroidAlarmPermissionGateway implements AlarmPermissionGateway {
  const AndroidAlarmPermissionGateway();

  static const _channel = MethodChannel(
    'com.senhoritaandriele.rotina/alarm_permissions',
  );

  @override
  Future<AlarmCapabilities> check() async {
    final statuses = await Future.wait([
      Permission.notification.status,
      Permission.accessNotificationPolicy.status,
    ]);
    final exactScheduling =
        await _channel.invokeMethod<bool>('canScheduleExactAlarms') ?? false;
    final fullScreen =
        await _channel.invokeMethod<bool>('canUseFullScreenIntent') ?? false;
    return AlarmCapabilities(
      notifications: statuses[0].isGranted,
      exactScheduling: exactScheduling,
      doNotDisturbAccess: statuses[1].isGranted,
      fullScreen: fullScreen,
    );
  }

  @override
  Future<AlarmCapabilities> requestRequiredAccess() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    if (!await Permission.accessNotificationPolicy.isGranted) {
      await Permission.accessNotificationPolicy.request();
    }
    if (!(await _channel.invokeMethod<bool>('canUseFullScreenIntent') ??
        false)) {
      await _channel.invokeMethod<void>('requestFullScreenIntent');
    }
    return check();
  }
}

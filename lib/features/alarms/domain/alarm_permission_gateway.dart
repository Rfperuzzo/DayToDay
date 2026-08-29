final class AlarmCapabilities {
  const AlarmCapabilities({
    required this.notifications,
    required this.exactScheduling,
    required this.fullScreen,
    required this.doNotDisturbAccess,
  });

  final bool notifications;
  final bool exactScheduling;
  final bool fullScreen;
  final bool doNotDisturbAccess;

  bool get fullyOperational =>
      notifications && exactScheduling && fullScreen && doNotDisturbAccess;
}

abstract interface class AlarmPermissionGateway {
  Future<AlarmCapabilities> check();

  Future<AlarmCapabilities> requestRequiredAccess();
}

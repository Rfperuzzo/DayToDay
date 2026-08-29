import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/time/clock.dart';
import '../core/time/iana_time_zone_service.dart';
import '../core/time/time_zone_service.dart';
import '../features/activities/data/drift_activity_repositories.dart';
import '../features/activities/application/activity_creator.dart';
import '../features/activities/application/activity_manager.dart';
import '../features/activities/domain/activity_repositories.dart';
import '../features/alarms/application/alarm_event_processor.dart';
import '../features/alarms/application/alarm_reconciler.dart';
import '../features/alarms/application/alarm_response_service.dart';
import '../features/alarms/domain/alarm_gateway.dart';
import '../features/alarms/domain/alarm_permission_gateway.dart';
import '../features/alarms/infrastructure/android_alarm_gateway.dart';
import '../features/alarms/infrastructure/android_alarm_permission_gateway.dart';
import '../features/history/data/drift_activity_event_repository.dart';
import '../features/history/domain/activity_event.dart';
import '../features/dashboard/application/occurrence_actions.dart';
import '../features/routine_engine/application/priority_routine_planner.dart';
import '../features/routine_engine/domain/routine_planner.dart';
import '../features/settings/domain/user_preferences.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('AppDatabase ainda não foi inicializado.'),
);
final timeZoneServiceProvider = Provider<TimeZoneService>(
  (ref) => throw StateError('TimeZoneService ainda não foi inicializado.'),
);
final alarmGatewayProvider = Provider<AlarmGateway>(
  (ref) => throw StateError('AlarmGateway ainda não foi inicializado.'),
);
final alarmPermissionGatewayProvider = Provider<AlarmPermissionGateway>(
  (ref) => throw StateError('AlarmPermissionGateway não foi inicializado.'),
);
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => DriftActivityRepository(ref.watch(databaseProvider)),
);
final occurrenceRepositoryProvider = Provider<OccurrenceRepository>(
  (ref) => DriftOccurrenceRepository(ref.watch(databaseProvider)),
);
final activityEventRepositoryProvider = Provider<ActivityEventRepository>(
  (ref) => DriftActivityEventRepository(ref.watch(databaseProvider)),
);
final routinePlannerProvider = Provider<RoutinePlanner>(
  (ref) => PriorityRoutinePlanner(ref.watch(timeZoneServiceProvider)),
);
final alarmReconcilerProvider = Provider<AlarmReconciler>(
  (ref) => AlarmReconciler(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    alarms: ref.watch(alarmGatewayProvider),
    clock: const SystemClock(),
  ),
);
final occurrenceActionsProvider = Provider<OccurrenceActions>(
  (ref) => OccurrenceActions(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    events: ref.watch(activityEventRepositoryProvider),
    alarms: ref.watch(alarmGatewayProvider),
    clock: const SystemClock(),
  ),
);
final userPreferencesProvider = Provider<UserPreferences>(
  (ref) => const UserPreferences(),
);
final activityCreatorProvider = Provider<ActivityCreator>(
  (ref) => ActivityCreator(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    timeZone: ref.watch(timeZoneServiceProvider),
    alarmReconciler: ref.watch(alarmReconcilerProvider),
    clock: const SystemClock(),
    preferences: ref.watch(userPreferencesProvider),
  ),
);
final activityManagerProvider = Provider<ActivityManager>(
  (ref) => ActivityManager(
    activities: ref.watch(activityRepositoryProvider),
    occurrences: ref.watch(occurrenceRepositoryProvider),
    events: ref.watch(activityEventRepositoryProvider),
    alarms: ref.watch(alarmGatewayProvider),
    alarmReconciler: ref.watch(alarmReconcilerProvider),
    timeZone: ref.watch(timeZoneServiceProvider),
    clock: const SystemClock(),
    preferences: ref.watch(userPreferencesProvider),
  ),
);
final alarmResponseServiceProvider = Provider<AlarmResponseService>(
  (ref) => AlarmResponseService(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    events: ref.watch(activityEventRepositoryProvider),
    alarms: ref.watch(alarmGatewayProvider),
    planner: ref.watch(routinePlannerProvider),
    alarmReconciler: ref.watch(alarmReconcilerProvider),
    clock: const SystemClock(),
    preferences: ref.watch(userPreferencesProvider),
  ),
);

final class AppDependencies {
  AppDependencies._({
    required this.database,
    required this.timeZone,
    required this.alarmGateway,
    required this.permissionGateway,
    required this.eventProcessor,
  });

  final AppDatabase database;
  final TimeZoneService timeZone;
  final AndroidAlarmGateway alarmGateway;
  final AlarmPermissionGateway permissionGateway;
  final AlarmEventProcessor eventProcessor;

  static Future<AppDependencies> create() async {
    final database = AppDatabase.defaults();
    final timeZone = await IanaTimeZoneService.create();
    final alarmGateway = AndroidAlarmGateway();
    await alarmGateway.initialize();
    final occurrences = DriftOccurrenceRepository(database);
    final events = DriftActivityEventRepository(database);
    final eventProcessor = AlarmEventProcessor(
      occurrences: occurrences,
      events: events,
      alarms: alarmGateway,
    )..start();
    return AppDependencies._(
      database: database,
      timeZone: timeZone,
      alarmGateway: alarmGateway,
      permissionGateway: const AndroidAlarmPermissionGateway(),
      eventProcessor: eventProcessor,
    );
  }

  Widget provideTo(Widget child) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        timeZoneServiceProvider.overrideWithValue(timeZone),
        alarmGatewayProvider.overrideWithValue(alarmGateway),
        alarmPermissionGatewayProvider.overrideWithValue(permissionGateway),
      ],
      child: child,
    );
  }
}

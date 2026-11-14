import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:rotina_jhenifer/main.dart';
import 'package:rotina_jhenifer/app/app_dependencies.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_subtask_repository.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/activities/domain/subtask.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/today_screen.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_permission_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_screen.dart';

final now = DateTime.parse('2026-11-14T16:10:23Z');
final gateway = PreviewAlarms();
late final Activity focus;
late final ActivityOccurrence active;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(NativeDatabase.memory());
  final activities = DriftActivityRepository(db);
  final occurrences = DriftOccurrenceRepository(db);
  final subtasks = DriftSubtaskRepository(db);
  final titles = ['Planejar o dia', 'Foco no projeto', 'Pausa para caminhar'];
  for (var i = 0; i < titles.length; i++) {
    final at = now.add(Duration(minutes: i == 0 ? -40 : 120 + (i - 1) * 45));
    final a = Activity(
      id: 'ux-$i',
      title: titles[i],
      notes: 'Reserve este momento para cuidar da sua rotina.',
      estimatedDuration: const Duration(minutes: 30),
      priority: i == 1 ? ActivityPriority.high : ActivityPriority.normal,
      recurrence: OneOffRecurrence(at),
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    final o = ActivityOccurrence(
      id: '${a.id}:${at.microsecondsSinceEpoch}',
      activityId: a.id,
      originalStartUtc: at,
      scheduledStartUtc: at,
      estimatedDuration: a.estimatedDuration,
      priority: a.priority,
      status: i == 0 ? OccurrenceStatus.completed : OccurrenceStatus.scheduled,
    );
    await activities.save(a);
    await occurrences.saveAll([o]);
    if (i == 1) {
      focus = a;
      active = o;
    }
  }
  await subtasks.save(
    Subtask(
      id: 'ux-sub-1',
      activityId: focus.id,
      title: 'Separar o material',
      position: 0,
      createdAtUtc: now,
    ),
  );
  await subtasks.save(
    Subtask(
      id: 'ux-sub-2',
      activityId: focus.id,
      title: 'Revisar as prioridades',
      position: 1,
      isCompleted: true,
      completedAtUtc: now,
      createdAtUtc: now,
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        timeZoneServiceProvider.overrideWithValue(const PreviewZone()),
        alarmGatewayProvider.overrideWithValue(gateway),
        alarmPermissionGatewayProvider.overrideWithValue(PreviewPermissions()),
      ],
      child: const DayToDayApp(home: PreviewMenu()),
    ),
  );
}

class PreviewMenu extends ConsumerWidget {
  const PreviewMenu({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Fixture UX local')),
    body: ListView(
      children: [
        ListTile(
          title: const Text('Painel e jornadas'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const TodayScreen()),
          ),
        ),
        ListTile(
          title: const Text('Rotina vazia'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => TodayDashboard(
                selectedDay: DateTime.now(),
                activities: const [],
                occurrences: const [],
                timeZone: const PreviewZone(),
                onDaySelected: (_) {},
                onComplete: (_) {},
                onAddRequested: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text('Alarme e resposta'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (ctx) => AlarmRingingScreen(
                alarm: RingingAlarmBinding(
                  occurrenceId: active.id,
                  nativeAlarmId: 42,
                  scheduledAtUtc: active.scheduledStartUtc,
                  title: focus.title,
                  body: focus.notes,
                  estimatedDuration: focus.estimatedDuration,
                ),
                onRespond: (response) async {
                  final result = await ref
                      .read(alarmResponseServiceProvider)
                      .respond(occurrenceId: active.id, response: response);
                  if (!ctx.mounted) return;
                  Navigator.pushReplacement(
                    ctx,
                    MaterialPageRoute<void>(
                      builder: (inner) => AlarmResolvedScreen(
                        title: focus.title,
                        result: result,
                        timeZone: const PreviewZone(),
                        onDone: () => Navigator.pop(inner),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class PreviewZone implements TimeZoneService {
  const PreviewZone();
  @override
  DateTime toLocal(DateTime d) => d.toUtc();
  @override
  DateTime localComponentsToUtc(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, d.hour, d.minute);
}

class PreviewPermissions implements AlarmPermissionGateway {
  @override
  Future<AlarmCapabilities> check() async => const AlarmCapabilities(
    notifications: false,
    exactScheduling: false,
    fullScreen: false,
    doNotDisturbAccess: false,
  );
  @override
  Future<AlarmCapabilities> requestRequiredAccess() async =>
      const AlarmCapabilities(
        notifications: false,
        exactScheduling: false,
        fullScreen: false,
        doNotDisturbAccess: false,
      );
}

class PreviewAlarms implements AlarmGateway {
  final items = <String, AlarmRequest>{};
  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();
  @override
  Stream<List<RingingAlarmBinding>> get ringing => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> schedule(AlarmRequest r) async {
    items[r.occurrenceId] = r;
  }

  @override
  Future<void> cancel(String id) async {
    items.remove(id);
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => [
    for (final r in items.values)
      ScheduledAlarmBinding(
        occurrenceId: r.occurrenceId,
        nativeAlarmId: 42,
        scheduledAtUtc: r.scheduledAtUtc,
      ),
  ];
  @override
  Future<void> acknowledge(AlarmPlatformEvent e) async {}
}

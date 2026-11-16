// Explicit AVD-only diagnostic entrypoint. Not imported by lib/main.dart.
// Uses the real schema4 repositories, planner, response service and Android gateway
// with an in-memory database so the user's persisted routine is never replaced.
import 'dart:async';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/core/time/clock.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/application/occurrence_generator.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_reconciler.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/infrastructure/android_alarm_gateway.dart';
import 'package:rotina_jhenifer/features/history/data/drift_activity_event_repository.dart';
import 'package:rotina_jhenifer/features/routine_engine/application/priority_routine_planner.dart';
import 'package:rotina_jhenifer/features/settings/domain/user_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!const bool.fromEnvironment('DAYTODAY_BOUNDARY_PROBE')) {
    runApp(const MaterialApp(home: Scaffold(body: Text('Ensaio desativado.'))));
    return;
  }
  final message = ValueNotifier(
    'Ensaio sintético DayToDay — banco em memória. Não publicar este APK.',
  );
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: message,
              builder: (_, value, _) =>
                  Text(value, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    ),
  );
  final db = AppDatabase(NativeDatabase.memory());
  final activities = DriftActivityRepository(db);
  final occurrences = DriftOccurrenceRepository(db);
  final events = DriftActivityEventRepository(db);
  final gateway = AndroidAlarmGateway();
  const clock = SystemClock();
  const zone = DeviceTimeZoneService();
  const preferences = UserPreferences();
  final reconciler = AlarmReconciler(
    activities: activities,
    occurrences: occurrences,
    alarms: gateway,
    clock: clock,
    timeZone: zone,
  );
  final responses = AlarmResponseService(
    occurrences: occurrences,
    events: events,
    alarms: gateway,
    planner: const PriorityRoutinePlanner(zone),
    alarmReconciler: reconciler,
    clock: clock,
    preferences: preferences,
  );
  final anchor = DateTime.fromMillisecondsSinceEpoch(
    (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) * 1000,
    isUtc: true,
  );
  final saved = <ActivityOccurrence>[];
  final observed = <String>[];
  final handled = <String>{};
  final finished = Completer<void>();
  StreamSubscription<List<RingingAlarmBinding>>? subscription;
  try {
    await gateway.initialize();
    Future<void> add(String id, int offset, {bool start = true}) async {
      final at = anchor.add(Duration(seconds: offset));
      final activity = Activity(
        id: 'probe-boundary-$id',
        title: id,
        estimatedDuration: const Duration(minutes: 1),
        priority: ActivityPriority.normal,
        recurrence: OneOffRecurrence(at),
        createdAtUtc: anchor,
        updatedAtUtc: anchor,
        usesBoundaryAlarms: true,
        notifyAtStart: start,
        notifyAtEnd: true,
      );
      await activities.save(activity);
      final occurrence = const OccurrenceGenerator(zone)
          .generate(
            activity: activity,
            fromUtc: anchor,
            untilUtc: anchor.add(const Duration(days: 1)),
          )
          .single;
      await occurrences.saveAll([occurrence]);
      saved.add(occurrence);
    }

    await add('Matemática', 12);
    await add('Português', 72);
    await add('Somente final', 142, start: false);
    subscription = gateway.ringing.listen((bindings) {
      for (final binding in bindings) {
        if (!saved.any((o) => o.id == binding.occurrenceId) ||
            !handled.add(binding.alarmKey)) {
          continue;
        }
        unawaited(() async {
          try {
            observed.add(binding.phase.name);
            message.value =
                'DISPARO REAL: ${binding.phase.name}\n${binding.title}\n${binding.body}';
            debugPrint(
              'DAYTODAY_BOUNDARY_RING ${jsonEncode({'phase': binding.phase.name, 'key': binding.alarmKey, 'title': binding.title, 'at': DateTime.now().toUtc().toIso8601String()})}',
            );
            await Future<void>.delayed(const Duration(seconds: 2));
            await responses.respond(
              occurrenceId: binding.occurrenceId,
              response: AlarmResponse.silence,
              phase: binding.phase,
              previousOccurrenceId: binding.previousOccurrenceId,
            );
            if (observed.length == 1) {
              final o = (await occurrences.findById(saved.first.id))!;
              if (o.endAcknowledgedAtUtc != null) {
                throw StateError(
                  'Initial silence incorrectly acknowledged final',
                );
              }
              if (!(await gateway.scheduled()).any(
                (b) => b.phase == AlarmPhase.transition,
              )) {
                throw StateError('Initial silence removed transition');
              }
            }
            if (observed.length == 4 && !finished.isCompleted) {
              finished.complete();
            }
          } catch (e, st) {
            if (!finished.isCompleted) finished.completeError(e, st);
          }
        }());
      }
    });
    await reconciler.reconcile(preferences);
    final initial = await gateway.scheduled();
    if (initial.length != 4 ||
        initial.where((a) => a.phase == AlarmPhase.transition).length != 1) {
      throw StateError(
        'Expected four native alarms including one merged transition',
      );
    }
    debugPrint(
      'DAYTODAY_BOUNDARY_PLAN ${jsonEncode(initial.map((r) => {'key': r.alarmKey, 'phase': r.phase.name, 'at': r.scheduledAtUtc.toIso8601String()}).toList())}',
    );
    message.value =
        'Ensaio real agendado: início + troca + final + somente final.\nDados sintéticos, banco em memória. Não publicar este APK.';
    await finished.future.timeout(const Duration(seconds: 235));
    final stored = await Future.wait(
      saved.map((o) => occurrences.findById(o.id)),
    );
    if (stored.any((o) => o!.status != OccurrenceStatus.scheduled)) {
      throw StateError('An alarm response completed or cancelled an activity');
    }
    if (stored.any((o) => o!.endAcknowledgedAtUtc == null)) {
      throw StateError('A final endpoint was not acknowledged');
    }
    if ((await gateway.scheduled()).any(
      (b) => saved.any((o) => o.id == b.occurrenceId),
    )) {
      throw StateError('Stale probe endpoint remains scheduled');
    }
    final result = {
      'passed': true,
      'phases': observed,
      'nativeAlarms': initial.length,
      'mergedTransitionCount': 1,
      'activityCount': stored.length,
      'allActivitiesRemainPending': true,
      'initialSilencePreservedFinal': true,
      'allEndAcknowledgementsPersisted': true,
      'database': 'schema4 real repositories, memory only',
      'productionUiEntrypoint': false,
    };
    message.value = 'ENSAIO APROVADO\n${jsonEncode(result)}';
    debugPrint('DAYTODAY_BOUNDARY_RESULT ${jsonEncode(result)}');
  } catch (e) {
    message.value = 'ENSAIO FALHOU: $e';
    debugPrint(
      'DAYTODAY_BOUNDARY_RESULT ${jsonEncode({'passed': false, 'error': e.toString(), 'phases': observed})}',
    );
  } finally {
    for (final o in saved) {
      await gateway.cancel(o.id);
      await gateway.cancel(AlarmIdentity.endKey(o.id));
    }
    await subscription?.cancel();
    await gateway.dispose();
    await db.close();
  }
}

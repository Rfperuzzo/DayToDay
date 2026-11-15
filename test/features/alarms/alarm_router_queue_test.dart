import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/app/app_dependencies.dart';
import 'package:rotina_jhenifer/core/database/app_database.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/data/drift_activity_repositories.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_router.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_screen.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  for (final scenario in ['both', 'same', 'empty', 'failure']) {
    testWidgets('resposta em andamento usa última fila: $scenario', (
      tester,
    ) async {
      final db = AppDatabase(NativeDatabase.memory());
      final gateway = _Gateway();
      final at = DateTime.now().toUtc().add(const Duration(minutes: 10));
      for (final id in ['a', 'b']) {
        await DriftActivityRepository(db).save(
          Activity(
            id: id,
            title: 'Aviso $id',
            kind: ActivityKind.reminder,
            estimatedDuration: Duration.zero,
            priority: ActivityPriority.normal,
            recurrence: OneOffRecurrence(at),
            createdAtUtc: at,
            updatedAtUtc: at,
          ),
        );
        await DriftOccurrenceRepository(db).saveAll([
          ActivityOccurrence(
            id: id,
            activityId: id,
            kind: ActivityKind.reminder,
            originalStartUtc: at,
            scheduledStartUtc: at,
            estimatedDuration: Duration.zero,
            priority: ActivityPriority.normal,
            status: OccurrenceStatus.scheduled,
          ),
        ]);
      }
      RingingAlarmBinding binding(String id) => RingingAlarmBinding(
        occurrenceId: id,
        nativeAlarmId: id == 'a' ? 1 : 2,
        scheduledAtUtc: at,
        title: 'Aviso $id',
        body: '',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            alarmGatewayProvider.overrideWithValue(gateway),
            timeZoneServiceProvider.overrideWithValue(
              const DeviceTimeZoneService(),
            ),
          ],
          child: const DayToDayApp(
            home: AlarmRouter(child: Text('Painel de teste')),
          ),
        ),
      );
      gateway.controller.add([binding('a')]);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Parar alarme'));
      await tester.tap(find.text('Parar alarme'));
      for (var i = 0; i < 30 && !gateway.entered; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(gateway.entered, isTrue);
      gateway.controller.add(
        scenario == 'same'
            ? [binding('a')]
            : scenario == 'both'
            ? [binding('a'), binding('b')]
            : [binding('b')],
      );
      await tester.pump();
      if (scenario == 'empty') {
        gateway.controller.add([]);
        await tester.pump();
      }
      if (scenario == 'failure') {
        gateway.gate.completeError(StateError('synthetic stop failure'));
      } else {
        gateway.gate.complete();
      }
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      if (scenario == 'both') {
        expect(find.byType(AlarmRingingScreen), findsOneWidget);
        expect(find.text('Aviso b'), findsOneWidget);
        expect(find.text('Aviso a'), findsNothing);
      } else if (scenario == 'failure') {
        expect(find.text('Aviso a'), findsOneWidget);
        expect(
          find.text('Não foi possível registrar a resposta. Tente novamente.'),
          findsOneWidget,
        );
        expect(find.text('Aviso b'), findsNothing);
      } else {
        expect(find.text('Aviso silenciado'), findsOneWidget);
        expect(find.byType(AlarmRingingScreen), findsNothing);
        await tester.ensureVisible(find.text('Voltar para minha rotina'));
        await tester.tap(find.text('Voltar para minha rotina'));
        await tester.pumpAndSettle();
        expect(find.text('Painel de teste'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await gateway.controller.close();
      await db.close();
    });
  }
}

class _Gateway implements AlarmGateway {
  final controller = StreamController<List<RingingAlarmBinding>>.broadcast();
  final gate = Completer<void>();
  bool entered = false;
  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();
  @override
  Stream<List<RingingAlarmBinding>> get ringing => controller.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> schedule(AlarmRequest request) async {}
  @override
  Future<void> cancel(String id) async {
    if (id == 'a' && !entered) {
      entered = true;
      await gate.future;
    }
  }

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => [];
  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}
}

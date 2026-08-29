import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rotina_jhenifer/app/app_dependencies.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/today_screen.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_screen.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_router.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  testWidgets('aplica identidade visual ao aplicativo', (tester) async {
    await tester.pumpWidget(
      const RotinaJheniferApp(
        home: Scaffold(body: Center(child: Text('Rotina da Jhenifer'))),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Rotina da Jhenifer'), findsOneWidget);
  });

  testWidgets('painel mostra progresso, próxima atividade e conclusão', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final now = DateTime.now();
    final scheduledAt = now.add(const Duration(minutes: 20)).toUtc();
    final activity = Activity(
      id: 'treino',
      title: 'Treino de pernas',
      estimatedDuration: const Duration(minutes: 60),
      priority: ActivityPriority.high,
      recurrence: OneOffRecurrence(scheduledAt),
      createdAtUtc: now.toUtc(),
      updatedAtUtc: now.toUtc(),
    );
    final occurrence = ActivityOccurrence(
      id: 'treino:${scheduledAt.microsecondsSinceEpoch}',
      activityId: activity.id,
      originalStartUtc: scheduledAt,
      scheduledStartUtc: scheduledAt,
      estimatedDuration: activity.estimatedDuration,
      priority: activity.priority,
      status: OccurrenceStatus.scheduled,
    );
    ActivityOccurrence? completed;
    ActivityOccurrence? managed;
    var addRequested = false;

    await tester.pumpWidget(
      RotinaJheniferApp(
        home: TodayDashboard(
          selectedDay: now,
          activities: [activity],
          occurrences: [occurrence],
          timeZone: const DeviceTimeZoneService(),
          onDaySelected: (_) {},
          onComplete: (value) => completed = value,
          onManage: (_, value) => managed = value,
          onAddRequested: () => addRequested = true,
        ),
      ),
    );

    expect(find.text('0 de 1 concluídas'), findsOneWidget);
    expect(find.text('Treino de pernas'), findsNWidgets(2));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('task-${occurrence.id}')));
    expect(managed, same(occurrence));
    await tester.tap(find.text('Concluir atividade'));
    expect(completed, same(occurrence));
    await tester.tap(find.byTooltip('Adicionar atividade'));
    expect(addRequested, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tela de alarme exige uma das três respostas', (tester) async {
    AlarmResponse? response;
    final scheduledAt = DateTime.now().toUtc();

    await tester.pumpWidget(
      RotinaJheniferApp(
        home: AlarmRingingScreen(
          alarm: RingingAlarmBinding(
            occurrenceId: 'treino-1',
            nativeAlarmId: 42,
            scheduledAtUtc: scheduledAt,
            title: 'Treino de pernas',
            body: 'Hora da sua atividade. Abra para responder.',
          ),
          onRespond: (value) => response = value,
        ),
      ),
    );

    expect(find.text('Treino de pernas'), findsOneWidget);
    expect(find.text('Concluir'), findsOneWidget);
    expect(find.text('Agora não — reorganizar'), findsOneWidget);
    expect(find.text('Pular somente hoje'), findsOneWidget);
    await tester.tap(find.text('Agora não — reorganizar'));
    expect(response, AlarmResponse.nowNot);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resultado do alarme usa o fuso configurado no app', (
    tester,
  ) async {
    final scheduledAt = DateTime.utc(2026, 8, 29, 19, 5);
    final occurrence = ActivityOccurrence(
      id: 'treino-reorganizado',
      activityId: 'treino',
      originalStartUtc: scheduledAt,
      scheduledStartUtc: scheduledAt,
      estimatedDuration: const Duration(minutes: 30),
      priority: ActivityPriority.normal,
      status: OccurrenceStatus.scheduled,
    );

    await tester.pumpWidget(
      RotinaJheniferApp(
        home: AlarmResolvedScreen(
          title: 'Treino',
          result: AlarmResponseResult(
            response: AlarmResponse.nowNot,
            occurrence: occurrence,
            adjustedOccurrences: [occurrence],
            alarmsSynchronized: true,
          ),
          timeZone: const _SaoPauloTimeZone(),
          onDone: () {},
        ),
      ),
    );

    expect(find.text('sábado, 16:05'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('roteador abre alarme já tocando na inicialização', (
    tester,
  ) async {
    final alarm = RingingAlarmBinding(
      occurrenceId: 'acordar-1',
      nativeAlarmId: 84,
      scheduledAtUtc: DateTime.now().toUtc(),
      title: 'Hora de acordar',
      body: 'Bom dia, Jhenifer!',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          alarmGatewayProvider.overrideWithValue(_RingingAlarmGateway(alarm)),
          timeZoneServiceProvider.overrideWithValue(
            const DeviceTimeZoneService(),
          ),
        ],
        child: const RotinaJheniferApp(
          home: AlarmRouter(child: Text('Painel diário')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hora de acordar'), findsOneWidget);
    expect(find.text('Painel diário'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

final class _RingingAlarmGateway implements AlarmGateway {
  const _RingingAlarmGateway(this.alarm);

  final RingingAlarmBinding alarm;

  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();

  @override
  Stream<List<RingingAlarmBinding>> get ringing => Stream.value([alarm]);

  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}

  @override
  Future<void> cancel(String occurrenceId) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(AlarmRequest request) async {}

  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => const [];
}

final class _SaoPauloTimeZone implements TimeZoneService {
  const _SaoPauloTimeZone();

  @override
  DateTime localComponentsToUtc(DateTime localComponents) => DateTime.utc(
    localComponents.year,
    localComponents.month,
    localComponents.day,
    localComponents.hour + 3,
    localComponents.minute,
  );

  @override
  DateTime toLocal(DateTime utc) {
    final shifted = utc.toUtc().subtract(const Duration(hours: 3));
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
    );
  }
}

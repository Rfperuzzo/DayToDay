import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/app/app_dependencies.dart';
import 'package:rotina_jhenifer/features/alarms/application/alarm_response_service.dart';
import 'package:rotina_jhenifer/features/alarms/domain/alarm_gateway.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_router.dart';
import 'package:rotina_jhenifer/features/alarms/presentation/alarm_screen.dart';
import 'package:rotina_jhenifer/main.dart';

void main() {
  for (final phase in [AlarmPhase.end, AlarmPhase.transition]) {
    testWidgets(
      '$phase tem parada explícita sem ações ambíguas sobre outra atividade',
      (tester) async {
        AlarmResponse? response;
        await tester.pumpWidget(
          DayToDayApp(
            home: AlarmRingingScreen(
              alarm: RingingAlarmBinding(
                occurrenceId: 'b',
                phase: phase,
                previousOccurrenceId: phase == AlarmPhase.transition
                    ? 'a'
                    : null,
                nativeAlarmId: 1,
                scheduledAtUtc: DateTime.utc(2026, 11, 16, 9),
                title: 'Matemática → Português',
                body: 'Aviso de bloco',
              ),
              onRespond: (v) => response = v,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(
            phase == AlarmPhase.end ? 'FINAL DO BLOCO' : 'HORA DE TROCAR',
          ),
          findsOneWidget,
        );
        expect(find.text('Concluir'), findsNothing);
        expect(find.text('Adiar atividade'), findsNothing);
        expect(find.text('Pular somente hoje'), findsNothing);
        await tester.ensureVisible(find.text('Parar alarme'));
        await tester.tap(find.text('Parar alarme'));
        expect(response, AlarmResponse.silence);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('roteador distingue início e final da mesma ocorrência', (
    tester,
  ) async {
    final gateway = _Gateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [alarmGatewayProvider.overrideWithValue(gateway)],
        child: const DayToDayApp(home: AlarmRouter(child: Text('Painel'))),
      ),
    );
    RingingAlarmBinding binding(AlarmPhase phase) => RingingAlarmBinding(
      occurrenceId: 'same-occurrence',
      phase: phase,
      nativeAlarmId: phase.index + 1,
      scheduledAtUtc: DateTime.utc(
        2026,
        11,
        16,
        phase == AlarmPhase.start ? 8 : 10,
      ),
      title: phase == AlarmPhase.start ? 'Começar estudo' : 'Fim do estudo',
      body: 'Aviso',
    );
    gateway.controller.add([binding(AlarmPhase.start)]);
    await tester.pumpAndSettle();
    expect(find.text('Começar estudo'), findsOneWidget);
    gateway.controller.add([binding(AlarmPhase.end)]);
    await tester.pumpAndSettle();
    expect(find.text('Fim do estudo'), findsOneWidget);
    expect(find.text('Começar estudo'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await gateway.controller.close();
  });
}

class _Gateway implements AlarmGateway {
  final controller = StreamController<List<RingingAlarmBinding>>.broadcast();
  @override
  Stream<List<RingingAlarmBinding>> get ringing => controller.stream;
  @override
  Stream<AlarmPlatformEvent> get events => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> cancel(String id) async {}
  @override
  Future<void> schedule(AlarmRequest r) async {}
  @override
  Future<List<ScheduledAlarmBinding>> scheduled() async => [];
  @override
  Future<void> acknowledge(AlarmPlatformEvent event) async {}
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/presentation/rotina_theme.dart';
import 'package:rotina_jhenifer/core/time/time_zone_service.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/today_screen.dart';

void main() {
  final at = DateTime.now().toUtc().add(const Duration(hours: 1));
  final activities = [
    for (var i = 0; i < 2; i++)
      Activity(
        id: 'a$i',
        title: i == 0
            ? 'Foco no projeto'
            : 'Ler e anotar as ideias para o próximo projeto',
        estimatedDuration: const Duration(minutes: 30),
        priority: ActivityPriority.high,
        recurrence: OneOffRecurrence(at.add(Duration(hours: i))),
        createdAtUtc: at,
        updatedAtUtc: at,
      ),
  ];
  final occurrences = [
    for (var i = 0; i < 2; i++)
      ActivityOccurrence(
        id: 'o$i',
        activityId: activities[i].id,
        originalStartUtc: at.add(Duration(hours: i)),
        scheduledStartUtc: at.add(Duration(hours: i)),
        estimatedDuration: activities[i].estimatedDuration,
        priority: activities[i].priority,
        status: OccurrenceStatus.scheduled,
      ),
  ];

  Widget host(double scale, ValueChanged<ActivityOccurrence> complete) =>
      MaterialApp(
        theme: RotinaTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: TodayDashboard(
          selectedDay: DateTime.now(),
          activities: activities,
          occurrences: occurrences,
          timeZone: const DeviceTimeZoneService(),
          onDaySelected: (_) {},
          onComplete: complete,
          onManage: (_, _) {},
          onAddRequested: () {},
        ),
      );

  testWidgets('ação atual vem antes do resumo e cabe no primeiro viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host(1, (_) {}));
    await tester.pumpAndSettle();
    final action = find.text('Concluir atividade');
    expect(
      tester.getBottomLeft(action).dy,
      lessThan(tester.getTopLeft(find.byTooltip('Adicionar atividade')).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('next-activity-card'))).dy,
      lessThan(tester.getTopLeft(find.textContaining('Progresso ·')).dy),
    );
    expect(find.text('Nova atividade'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320dp e texto 2x mantêm leitura e bloqueio da próxima tarefa', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    ActivityOccurrence? completed;
    await tester.pumpWidget(host(2, (value) => completed = value));
    await tester.pumpAndSettle();
    final next = find.byKey(const ValueKey('complete-o1'));
    await tester.ensureVisible(next);
    await tester.pumpAndSettle();
    await tester.tap(next);
    expect(completed, isNull);
    expect(find.text('Após concluir a anterior · Importante'), findsOneWidget);
    expect(find.textContaining('30 min'), findsWidgets);
    final first = find.byKey(const ValueKey('complete-o0'));
    await tester.ensureVisible(first);
    await tester.pumpAndSettle();
    await tester.tap(first);
    expect(completed, same(occurrences.first));
    expect(tester.takeException(), isNull);
  });
}

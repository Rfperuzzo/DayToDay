import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity.dart';
import 'package:rotina_jhenifer/features/activities/domain/activity_occurrence.dart';
import 'package:rotina_jhenifer/features/activities/domain/recurrence_rule.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/today_screen.dart';
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
    var addRequested = false;

    await tester.pumpWidget(
      RotinaJheniferApp(
        home: TodayDashboard(
          selectedDay: now,
          activities: [activity],
          occurrences: [occurrence],
          onDaySelected: (_) {},
          onComplete: (value) => completed = value,
          onAddRequested: () => addRequested = true,
        ),
      ),
    );

    expect(find.text('0 de 1 concluídas'), findsOneWidget);
    expect(find.text('Treino de pernas'), findsNWidgets(2));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluir atividade'));
    expect(completed, same(occurrence));
    await tester.tap(find.byTooltip('Adicionar atividade'));
    expect(addRequested, isTrue);
    expect(tester.takeException(), isNull);
  });
}

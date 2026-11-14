import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/core/presentation/rotina_theme.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/continuous_month_calendar.dart';

void main() {
  testWidgets('botões de semana navegam sem mudar a data escolhida', (
    tester,
  ) async {
    final selected = <DateTime>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: RotinaTheme.light,
        home: Scaffold(
          body: ContinuousMonthCalendar(
            selectedDay: DateTime(2026, 8, 29),
            onSelected: selected.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(find.text('Setembro de 2026'), findsOneWidget);
    expect(selected, isEmpty);
    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    expect(find.text('Agosto de 2026'), findsOneWidget);
    expect(selected, isEmpty);
  });

  testWidgets('Hoje revela a data e respeita redução de movimento', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: RotinaTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: ContinuousMonthCalendar(
            selectedDay: DateTime(2026, 8, 29),
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hoje'));
    await tester.pumpAndSettle();
    expect(selected, DateUtils.dateOnly(DateTime.now()));
    final animations = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(animations, isNotEmpty);
    expect(animations.every((a) => a.duration == Duration.zero), isTrue);
    expect(tester.takeException(), isNull);
  });
}

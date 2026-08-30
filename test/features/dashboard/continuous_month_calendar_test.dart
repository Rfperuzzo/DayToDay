import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotina_jhenifer/features/dashboard/presentation/continuous_month_calendar.dart';

void main() {
  test('calcula meses com 28, 29, 30 e 31 dias', () {
    expect(daysInCalendarMonth(2025, DateTime.february), 28);
    expect(daysInCalendarMonth(2024, DateTime.february), 29);
    expect(daysInCalendarMonth(2026, DateTime.april), 30);
    expect(daysInCalendarMonth(2026, DateTime.august), 31);
  });

  testWidgets('rolagem muda o mês visível sem selecionar outro dia', (
    tester,
  ) async {
    final selected = <DateTime>[];
    final visibleMonths = <DateTime>[];
    await tester.pumpWidget(
      _CalendarHost(
        selectedDay: DateTime(2026, 8, 29),
        onSelected: selected.add,
        onVisibleMonthChanged: visibleMonths.add,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agosto de 2026'), findsOneWidget);
    expect(visibleMonths, contains(DateTime(2026, 8)));

    await tester.drag(
      find.byKey(const ValueKey('continuous-month-calendar-list')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Setembro de 2026'), findsOneWidget);
    expect(selected, isEmpty);
    expect(visibleMonths, contains(DateTime(2026, 9)));

    await tester.tap(find.byKey(const ValueKey('calendar-day-2026-09-04')));
    expect(selected.single, DateTime(2026, 9, 4));
  });

  testWidgets('mudança externa revela a data e atravessa a virada do ano', (
    tester,
  ) async {
    final selectedDay = ValueNotifier(DateTime(2026, 12, 29));
    addTearDown(selectedDay.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: ValueListenableBuilder<DateTime>(
                valueListenable: selectedDay,
                builder: (context, value, child) => ContinuousMonthCalendar(
                  selectedDay: value,
                  onSelected: (day) => selectedDay.value = day,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dezembro de 2026'), findsOneWidget);

    selectedDay.value = DateTime(2027, 1, 15);
    await tester.pumpAndSettle();

    expect(find.text('Janeiro de 2027'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-day-2027-01-15')),
      findsOneWidget,
    );
  });
}

final class _CalendarHost extends StatelessWidget {
  const _CalendarHost({
    required this.selectedDay,
    required this.onSelected,
    required this.onVisibleMonthChanged,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime> onVisibleMonthChanged;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 420,
            child: ContinuousMonthCalendar(
              selectedDay: selectedDay,
              onSelected: onSelected,
              onVisibleMonthChanged: onVisibleMonthChanged,
            ),
          ),
        ),
      ),
    );
  }
}

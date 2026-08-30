import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/presentation/rotina_theme.dart';

final class ContinuousMonthCalendar extends StatefulWidget {
  const ContinuousMonthCalendar({
    required this.selectedDay,
    required this.onSelected,
    this.onVisibleMonthChanged,
    super.key,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime>? onVisibleMonthChanged;

  @override
  State<ContinuousMonthCalendar> createState() =>
      _ContinuousMonthCalendarState();
}

final class _ContinuousMonthCalendarState
    extends State<ContinuousMonthCalendar> {
  static final _firstDay = DateTime(2000);
  static final _lastDayExclusive = DateTime(2101);
  static final _itemCount = _calendarDayDifference(
    _firstDay,
    _lastDayExclusive,
  );
  static const _spacing = 8.0;

  final ScrollController _controller = ScrollController();
  late DateTime _visibleMonth;
  DateTime? _lastNotifiedMonth;
  Timer? _monthNotificationTimer;
  double? _itemExtent;
  double? _viewportWidth;
  bool _initialPositionScheduled = false;

  @override
  void initState() {
    super.initState();
    _visibleMonth = _monthOnly(widget.selectedDay);
    _controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant ContinuousMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameDay(oldWidget.selectedDay, widget.selectedDay)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _revealSelectedDay();
        }
      });
    }
  }

  @override
  void dispose() {
    _monthNotificationTimer?.cancel();
    _controller
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _monthYearLabel(_visibleMonth),
          key: const ValueKey('calendar-month-label'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: RotinaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemExtent = (constraints.maxWidth + _spacing) / 7;
              _updateMetrics(constraints.maxWidth, itemExtent);
              return ListView.builder(
                key: const ValueKey('continuous-month-calendar-list'),
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: _itemCount,
                itemExtent: itemExtent,
                itemBuilder: (context, index) {
                  final day = _dateAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: _spacing),
                    child: _CalendarDayCard(
                      day: day,
                      selected: _sameDay(day, widget.selectedDay),
                      onTap: () => widget.onSelected(day),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateMetrics(double viewportWidth, double itemExtent) {
    final metricsChanged =
        _viewportWidth != viewportWidth || _itemExtent != itemExtent;
    _viewportWidth = viewportWidth;
    _itemExtent = itemExtent;
    if (!_initialPositionScheduled) {
      _initialPositionScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }
        _jumpToSelectedDay();
      });
    } else if (metricsChanged && _controller.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _jumpToSelectedDay();
        }
      });
    }
  }

  void _jumpToSelectedDay() {
    final target = _centerOffsetFor(widget.selectedDay);
    _controller.jumpTo(target.clamp(0.0, _controller.position.maxScrollExtent));
    _updateVisibleMonth();
  }

  void _revealSelectedDay() {
    if (!_controller.hasClients ||
        _itemExtent == null ||
        _viewportWidth == null) {
      return;
    }
    final index = _indexFor(widget.selectedDay);
    final left = index * _itemExtent!;
    final right = left + _itemExtent! - _spacing;
    final viewportLeft = _controller.offset;
    final viewportRight = viewportLeft + _viewportWidth!;
    if (left >= viewportLeft && right <= viewportRight) {
      return;
    }
    final target = _centerOffsetFor(
      widget.selectedDay,
    ).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  double _centerOffsetFor(DateTime day) {
    final itemExtent = _itemExtent!;
    final cardWidth = itemExtent - _spacing;
    return _indexFor(day) * itemExtent - (_viewportWidth! - cardWidth) / 2;
  }

  void _handleScroll() => _updateVisibleMonth();

  void _updateVisibleMonth() {
    if (!_controller.hasClients ||
        _itemExtent == null ||
        _viewportWidth == null) {
      return;
    }
    final center = _controller.offset + _viewportWidth! / 2;
    final index = (center / _itemExtent!).floor().clamp(0, _itemCount - 1);
    final month = _monthOnly(_dateAt(index));
    if (!_sameMonth(month, _visibleMonth)) {
      setState(() => _visibleMonth = month);
    }
    if (_lastNotifiedMonth != null && _sameMonth(month, _lastNotifiedMonth!)) {
      _monthNotificationTimer?.cancel();
      _monthNotificationTimer = null;
      return;
    }
    _monthNotificationTimer?.cancel();
    _monthNotificationTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted || !_sameMonth(month, _visibleMonth)) {
        return;
      }
      _lastNotifiedMonth = month;
      widget.onVisibleMonthChanged?.call(month);
    });
  }

  int _indexFor(DateTime day) => _calendarDayDifference(
    _firstDay,
    _clampDay(day, _firstDay, _lastDayExclusive),
  );

  DateTime _dateAt(int index) {
    final utc = DateTime.utc(2000).add(Duration(days: index));
    return DateTime(utc.year, utc.month, utc.day);
  }
}

final class _CalendarDayCard extends StatelessWidget {
  const _CalendarDayCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: _longDateLabel(day),
      child: InkWell(
        key: ValueKey('calendar-day-${_dayKey(day)}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          decoration: BoxDecoration(
            color: selected ? RotinaColors.primary : RotinaColors.surfaceStrong,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x40BA0034),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _weekdayShort(day.weekday),
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFFFDADA)
                      : RotinaColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.day}',
                style: TextStyle(
                  color: selected ? Colors.white : RotinaColors.text,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int daysInCalendarMonth(int year, int month) =>
    DateTime(year, month + 1).subtract(const Duration(days: 1)).day;

int _calendarDayDifference(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

DateTime _clampDay(DateTime day, DateTime minimum, DateTime maximumExclusive) {
  final normalized = DateTime(day.year, day.month, day.day);
  if (normalized.isBefore(minimum)) {
    return minimum;
  }
  if (!normalized.isBefore(maximumExclusive)) {
    return maximumExclusive.subtract(const Duration(days: 1));
  }
  return normalized;
}

DateTime _monthOnly(DateTime day) => DateTime(day.year, day.month);

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

bool _sameMonth(DateTime left, DateTime right) =>
    left.year == right.year && left.month == right.month;

String _dayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

String _weekdayShort(int weekday) =>
    const ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'][weekday - 1];

String _monthYearLabel(DateTime month) {
  const months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  return '${months[month.month - 1]} de ${month.year}';
}

String _longDateLabel(DateTime date) {
  const weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de '
      '${months[date.month - 1]} de ${date.year}';
}

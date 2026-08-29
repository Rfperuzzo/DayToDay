import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/presentation/rotina_theme.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/presentation/new_activity_sheet.dart';
import '../application/day_providers.dart';

final class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final activities = ref.watch(activeActivitiesProvider);
    final occurrences = ref.watch(dayOccurrencesProvider(selectedDay));

    return activities.when(
      data: (activityItems) => occurrences.when(
        data: (occurrenceItems) => TodayDashboard(
          selectedDay: selectedDay,
          activities: activityItems,
          occurrences: occurrenceItems,
          timeZone: ref.watch(timeZoneServiceProvider),
          onDaySelected: ref.read(selectedDayProvider.notifier).select,
          onAddRequested: () => _openNewActivity(context, ref, selectedDay),
          onComplete: (occurrence) async {
            try {
              await HapticFeedback.mediumImpact();
              await ref.read(occurrenceActionsProvider).complete(occurrence);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não foi possível concluir esta atividade.'),
                  ),
                );
              }
            }
          },
        ),
        loading: () => const _DashboardLoading(),
        error: (error, stackTrace) => const _DashboardError(),
      ),
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => const _DashboardError(),
    );
  }

  Future<void> _openNewActivity(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
  ) async {
    final outcome = await showModalBottomSheet<NewActivityOutcome>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: RotinaColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => NewActivitySheet(
        initialDay: selectedDay,
        timeZone: ref.read(timeZoneServiceProvider),
        permissions: ref.read(alarmPermissionGatewayProvider),
        onCreate: ref.read(activityCreatorProvider).create,
      ),
    );
    if (outcome == null || !context.mounted) {
      return;
    }
    final message = outcome.fullyReady
        ? 'Atividade salva e alarme preparado. ✨'
        : 'Atividade salva. Revise os acessos para o alarme funcionar com força total.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final class TodayDashboard extends StatelessWidget {
  const TodayDashboard({
    required this.selectedDay,
    required this.activities,
    required this.occurrences,
    required this.timeZone,
    required this.onDaySelected,
    required this.onComplete,
    this.onAddRequested,
    super.key,
  });

  final DateTime selectedDay;
  final List<Activity> activities;
  final List<ActivityOccurrence> occurrences;
  final TimeZoneService timeZone;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<ActivityOccurrence> onComplete;
  final VoidCallback? onAddRequested;

  @override
  Widget build(BuildContext context) {
    final activitiesById = {for (final item in activities) item.id: item};
    final sortedOccurrences = [...occurrences]
      ..sort(
        (left, right) =>
            left.scheduledStartUtc.compareTo(right.scheduledStartUtc),
      );
    final completed = sortedOccurrences
        .where((item) => item.status == OccurrenceStatus.completed)
        .length;
    final next = _findNextOccurrence(sortedOccurrences);

    return Scaffold(
      floatingActionButton: onAddRequested == null
          ? null
          : FloatingActionButton.large(
              onPressed: onAddRequested,
              tooltip: 'Adicionar atividade',
              backgroundColor: RotinaColors.primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 34),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _BrandHeader()),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Welcome(
                          selectedDay: selectedDay,
                          total: sortedOccurrences.length,
                        ),
                        const SizedBox(height: 26),
                        _WeekStrip(
                          selectedDay: selectedDay,
                          onSelected: onDaySelected,
                        ),
                        const SizedBox(height: 34),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cards = [
                              _ProgressCard(
                                completed: completed,
                                total: sortedOccurrences.length,
                              ),
                              _NextActivityCard(
                                occurrence: next,
                                timeZone: timeZone,
                                activity: next == null
                                    ? null
                                    : activitiesById[next.activityId],
                                onComplete: next == null
                                    ? null
                                    : () => onComplete(next),
                              ),
                            ];
                            if (constraints.maxWidth >= 700) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    var index = 0;
                                    index < cards.length;
                                    index++
                                  ) ...[
                                    Expanded(child: cards[index]),
                                    if (index == 0) const SizedBox(width: 16),
                                  ],
                                ],
                              );
                            }
                            return Column(
                              children: [
                                cards.first,
                                const SizedBox(height: 16),
                                cards.last,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'Tarefas do dia',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        if (sortedOccurrences.isEmpty)
                          const _EmptyRoutine()
                        else
                          ...sortedOccurrences.map(
                            (occurrence) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TaskTile(
                                occurrence: occurrence,
                                timeZone: timeZone,
                                activity: activitiesById[occurrence.activityId],
                                isNext: occurrence.id == next?.id,
                                onComplete: () => onComplete(occurrence),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ActivityOccurrence? _findNextOccurrence(
    List<ActivityOccurrence> sortedOccurrences,
  ) {
    final now = DateTime.now().toUtc();
    for (final item in sortedOccurrences) {
      if (item.status == OccurrenceStatus.scheduled &&
          item.scheduledEndUtc.isAfter(now)) {
        return item;
      }
    }
    return null;
  }
}

final class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RotinaColors.background,
        border: Border(bottom: BorderSide(color: RotinaColors.surfaceStrong)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: RotinaColors.surface,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: RotinaColors.outline),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: RotinaColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rotina da Jhenifer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: RotinaColors.primary,
                      fontSize: 22,
                    ),
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: RotinaColors.surfaceStrong,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'J',
                    style: TextStyle(
                      color: RotinaColors.textMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _Welcome extends StatelessWidget {
  const _Welcome({required this.selectedDay, required this.total});

  final DateTime selectedDay;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isToday = dateOnly(selectedDay) == dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _longDate(selectedDay),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        Text(
          isToday ? 'Olá, Jhenifer! ✨' : 'Seu dia em foco ✨',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: isToday
                    ? 'Pronta para conquistar o dia? Você tem '
                    : 'Você planejou ',
              ),
              TextSpan(
                text: '$total ${total == 1 ? 'tarefa' : 'tarefas'}',
                style: const TextStyle(
                  color: RotinaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: ' por aqui.'),
            ],
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

final class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedDay, required this.onSelected});

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final weekStart = selectedDay.subtract(
      Duration(days: selectedDay.weekday - 1),
    );
    return SizedBox(
      height: 82,
      child: Row(
        children: [
          for (var index = 0; index < 7; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: Builder(
                builder: (context) {
                  final day = dateOnly(weekStart.add(Duration(days: index)));
                  final selected = day == dateOnly(selectedDay);
                  return Semantics(
                    selected: selected,
                    label: _longDate(day),
                    child: InkWell(
                      onTap: () => onSelected(day),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selected
                              ? RotinaColors.primary
                              : RotinaColors.surfaceStrong,
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
                                color: selected
                                    ? Colors.white
                                    : RotinaColors.text,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progresso',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('$completed de $total concluídas'),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: const ShapeDecoration(
                      color: RotinaColors.primarySoft,
                      shape: StadiumBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      child: Text(
                        total == 0
                            ? 'Vamos começar? 🌷'
                            : completed == total
                            ? 'Dia conquistado! ✨'
                            : 'Mantenha o ritmo! 🔥',
                        style: const TextStyle(
                          color: RotinaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _ProgressRing(progress: progress),
          ],
        ),
      ),
    );
  }
}

final class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => CustomPaint(
              size: const Size.square(96),
              painter: _ProgressRingPainter(value),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: RotinaColors.primary),
          ),
        ],
      ),
    );
  }
}

final class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 10.0;
    final background = Paint()
      ..color = RotinaColors.surfaceStrong
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final foreground = Paint()
      ..shader = const LinearGradient(
        colors: [RotinaColors.primary, Color(0xFFFF5C72)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, background);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        foreground,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

final class _NextActivityCard extends StatelessWidget {
  const _NextActivityCard({
    required this.timeZone,
    this.occurrence,
    this.activity,
    this.onComplete,
  });

  final TimeZoneService timeZone;
  final ActivityOccurrence? occurrence;
  final Activity? activity;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final occurrence = this.occurrence;
    final activity = this.activity;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RotinaColors.primaryBright,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33BA0034),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    occurrence == null
                        ? 'Agenda livre'
                        : '${_relativeLabel(occurrence.scheduledStartUtc)} • ${_time(timeZone, occurrence.scheduledStartUtc)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            activity?.title ?? 'Nenhuma próxima tarefa',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 27,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            occurrence == null
                ? 'Um espaço para respirar ou planejar algo especial.'
                : '${activity?.notes.isNotEmpty == true ? activity!.notes : 'Atividade planejada'} • ${occurrence.estimatedDuration.inMinutes} min',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          if (occurrence != null) ...[
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: RotinaColors.primary,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text('Concluir atividade'),
            ),
          ],
        ],
      ),
    );
  }
}

final class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.occurrence,
    required this.timeZone,
    required this.activity,
    required this.isNext,
    required this.onComplete,
  });

  final ActivityOccurrence occurrence;
  final TimeZoneService timeZone;
  final Activity? activity;
  final bool isNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final completed = occurrence.status == OccurrenceStatus.completed;
    final active = !completed && isNext;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: completed ? 0.62 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: active ? RotinaColors.surfaceStrong : RotinaColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? RotinaColors.primary : RotinaColors.outline,
          ),
        ),
        child: Row(
          children: [
            Semantics(
              button: !completed,
              checked: completed,
              label: completed ? 'Atividade concluída' : 'Concluir atividade',
              child: InkWell(
                onTap: completed ? null : onComplete,
                customBorder: const CircleBorder(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: completed
                        ? RotinaColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed
                          ? RotinaColors.primary
                          : RotinaColors.outline,
                      width: 3,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 23,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity?.title ?? 'Atividade',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: RotinaColors.text,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_time(timeZone, occurrence.scheduledStartUtc)} • ${occurrence.estimatedDuration.inMinutes} min',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: active
                          ? RotinaColors.primary
                          : RotinaColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _priorityIcon(occurrence.priority),
              color: active ? RotinaColors.primary : RotinaColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: RotinaColors.surfaceSoft,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: RotinaColors.primary,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            'Seu dia está livre',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Quando você adicionar uma atividade, ela aparecerá aqui com seu horário e progresso.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

final class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

final class _DashboardError extends StatelessWidget {
  const _DashboardError();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: RotinaColors.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Não conseguimos abrir a rotina.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Feche e abra o app novamente. Seus dados continuam salvos no aparelho.',
            ),
          ],
        ),
      ),
    ),
  );
}

String _weekdayShort(int weekday) =>
    const ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'][weekday - 1];

String _longDate(DateTime date) {
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
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}

String _time(TimeZoneService timeZone, DateTime utc) {
  final local = timeZone.toLocal(utc);
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String _relativeLabel(DateTime utc) {
  final now = DateTime.now().toUtc();
  if (!utc.isAfter(now) && utc.add(const Duration(hours: 2)).isAfter(now)) {
    return 'Agora';
  }
  return 'Próxima';
}

IconData _priorityIcon(ActivityPriority priority) => switch (priority) {
  ActivityPriority.high => Icons.bolt_rounded,
  ActivityPriority.normal => Icons.favorite_rounded,
  ActivityPriority.low => Icons.spa_rounded,
};

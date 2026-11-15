import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/presentation/rotina_theme.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/application/activity_manager.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../activities/presentation/activity_options_sheet.dart';
import '../../activities/presentation/new_activity_sheet.dart';
import '../../activities/presentation/subtasks_sheet.dart';
import '../../alarms/presentation/alarm_access_sheet.dart';
import '../../alarms/application/alarm_response_service.dart';
import '../../home_widget/domain/day_widget_gateway.dart';
import '../../privacy/presentation/privacy_screen.dart';
import '../application/day_providers.dart';
import '../application/daily_task_sequence.dart';
import 'continuous_month_calendar.dart';

final class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetRequest = ref.watch(dayWidgetOpenRequestProvider);
    if (widgetRequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final request = ref.read(dayWidgetOpenRequestProvider.notifier).take();
        if (request != null && context.mounted) {
          _openWidgetTask(context, ref, request);
        }
      });
    }
    final selectedDay = ref.watch(selectedDayProvider);
    final activities = ref.watch(allActivitiesProvider);
    final occurrences = ref.watch(dayOccurrencesProvider(selectedDay));

    return activities.when(
      data: (activityItems) => occurrences.when(
        data: (occurrenceItems) => TodayDashboard(
          selectedDay: selectedDay,
          activities: activityItems,
          occurrences: occurrenceItems,
          timeZone: ref.watch(timeZoneServiceProvider),
          onDaySelected: (day) => _selectDay(ref, activityItems, day),
          onVisibleMonthChanged: (month) =>
              _prepareVisibleMonth(ref, activityItems, month),
          onAddRequested: () => _openNewActivity(context, ref, selectedDay),
          onAlarmAccessRequested: () => _reviewAlarmAccess(context, ref),
          onManage: (activity, occurrence) =>
              _openActivityOptions(context, ref, activity, occurrence),
          onComplete: (occurrence) =>
              _completeOccurrence(context, ref, occurrence),
        ),
        loading: () => const _DashboardLoading(),
        error: (error, stackTrace) => _DashboardError(
          onRetry: () {
            ref.invalidate(allActivitiesProvider);
            ref.invalidate(dayOccurrencesProvider(selectedDay));
          },
        ),
      ),
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => _DashboardError(
        onRetry: () {
          ref.invalidate(allActivitiesProvider);
          ref.invalidate(dayOccurrencesProvider(selectedDay));
        },
      ),
    );
  }

  Future<void> _reviewAlarmAccess(BuildContext context, WidgetRef ref) async {
    await showAlarmAccessSheet(
      context,
      ref.read(alarmPermissionGatewayProvider),
    );
    if (!context.mounted) return;
    try {
      await ref
          .read(alarmReconcilerProvider)
          .reconcile(ref.read(userPreferencesProvider));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A rotina está salva. Não foi possível preparar todos os alarmes; revise os acessos e tente novamente.',
          ),
        ),
      );
    }
  }

  Future<void> _openNewActivity(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDay,
  ) async {
    final outcome = await showModalBottomSheet<NewActivityOutcome>(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
        ? 'Atividade salva e alarme preparado.'
        : 'Atividade salva. Revise os acessos para o alarme funcionar com força total.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: outcome.fullyReady
            ? null
            : SnackBarAction(
                label: 'Revisar',
                onPressed: () => _reviewAlarmAccess(context, ref),
              ),
      ),
    );
  }

  void _prepareVisibleMonth(
    WidgetRef ref,
    List<Activity> activities,
    DateTime month,
  ) {
    unawaited(() async {
      try {
        await ref
            .read(occurrenceHorizonMaintainerProvider)
            .ensureMonth(activities: activities, localMonth: month);
      } catch (_) {
        // As tarefas já persistidas continuam disponíveis em modo degradado.
      }
    }());
  }

  void _selectDay(WidgetRef ref, List<Activity> activities, DateTime day) {
    ref.read(selectedDayProvider.notifier).select(day);
    _prepareVisibleMonth(ref, activities, DateTime(day.year, day.month));
  }

  Future<void> _openActivityOptions(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
    ActivityOccurrence occurrence, {
    bool showComplete = false,
  }) async {
    await HapticFeedback.selectionClick();
    if (!context.mounted) {
      return;
    }
    final option = await showModalBottomSheet<ActivityOption>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: RotinaColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => ActivityOptionsSheet(
        activity: activity,
        occurrence: occurrence,
        timeZone: ref.read(timeZoneServiceProvider),
        showComplete: showComplete,
      ),
    );
    if (option == null || !context.mounted) {
      return;
    }
    switch (option) {
      case ActivityOption.postpone:
        await _postponeReminder(context, ref, occurrence);
      case ActivityOption.complete:
        await _completeOccurrence(context, ref, occurrence);
      case ActivityOption.edit:
        await _editActivity(context, ref, activity, occurrence);
      case ActivityOption.subtasks:
        await _openSubtasks(context, activity);
      case ActivityOption.cancel:
        await _cancelActivity(context, ref, activity, occurrence);
    }
  }

  Future<void> _postponeReminder(
    BuildContext context,
    WidgetRef ref,
    ActivityOccurrence occurrence,
  ) async {
    if (!occurrence.isReminder) return;
    try {
      final result = await ref
          .read(alarmResponseServiceProvider)
          .respond(occurrenceId: occurrence.id, response: AlarmResponse.nowNot);
      if (!context.mounted) return;
      final local = ref
          .read(timeZoneServiceProvider)
          .toLocal(result.occurrence.scheduledStartUtc);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.alarmsSynchronized
                ? 'Lembrete adiado para ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}.'
                : 'Lembrete adiado. Revise os acessos do alarme.',
          ),
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível adiar o lembrete. Tente novamente.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openWidgetTask(
    BuildContext context,
    WidgetRef ref,
    DayWidgetOpenRequest request,
  ) async {
    final occurrence = await ref
        .read(occurrenceRepositoryProvider)
        .findById(request.occurrenceId);
    final activity = await ref
        .read(activityRepositoryProvider)
        .findById(request.activityId);
    if (!context.mounted) {
      return;
    }
    if (occurrence == null ||
        activity == null ||
        !activity.isActive ||
        occurrence.activityId != activity.id ||
        occurrence.status == OccurrenceStatus.cancelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Essa tarefa não está mais disponível.')),
      );
      return;
    }
    final timeZone = ref.read(timeZoneServiceProvider);
    final local = timeZone.toLocal(occurrence.scheduledStartUtc);
    final localDay = DateTime(local.year, local.month, local.day);
    ref.read(selectedDayProvider.notifier).select(localDay);
    final dayStartUtc = timeZone.localComponentsToUtc(localDay);
    final dayEndUtc = timeZone.localComponentsToUtc(
      localDay.add(const Duration(days: 1)),
    );
    final pending = await ref
        .read(occurrenceRepositoryProvider)
        .findScheduledBetween(dayStartUtc, dayEndUtc);
    final available = DailyTaskSequence.firstAvailable(pending);
    final showComplete =
        occurrence.status == OccurrenceStatus.scheduled &&
        !DailyTaskSequence.isLocked(
          occurrence: occurrence,
          available: available,
        );
    if (context.mounted) {
      await _openActivityOptions(
        context,
        ref,
        activity,
        occurrence,
        showComplete: showComplete,
      );
    }
  }

  Future<void> _completeOccurrence(
    BuildContext context,
    WidgetRef ref,
    ActivityOccurrence occurrence,
  ) async {
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
  }

  Future<void> _openSubtasks(BuildContext context, Activity activity) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: RotinaColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SubtasksSheet(activity: activity),
    );
  }

  Future<void> _editActivity(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
    ActivityOccurrence occurrence,
  ) async {
    final result = await showModalBottomSheet<ActivityMutationResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => EditActivitySheet(
        activity: activity,
        occurrence: occurrence,
        timeZone: ref.read(timeZoneServiceProvider),
        onSave: (draft) => ref
            .read(activityManagerProvider)
            .edit(selectedOccurrence: occurrence, draft: draft),
      ),
    );
    if (result == null || !context.mounted) return;
    final message = result.alarmsSynchronized
        ? 'Atividade e próximos alarmes atualizados.'
        : 'Atividade atualizada. Revise os acessos do alarme.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancelActivity(
    BuildContext context,
    WidgetRef ref,
    Activity activity,
    ActivityOccurrence occurrence,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cancel_outlined, color: RotinaColors.danger),
        title: const Text('Cancelar atividade?'),
        content: Text(
          '“${activity.title}” será desativada e todos os próximos alarmes serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: RotinaColors.danger),
            child: const Text('Cancelar atividade'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      final result = await ref
          .read(activityManagerProvider)
          .cancel(selectedOccurrence: occurrence);
      await HapticFeedback.mediumImpact();
      if (context.mounted) {
        final message = result.alarmsSynchronized
            ? 'Atividade cancelada e alarmes removidos.'
            : 'Atividade cancelada. Revise os acessos do alarme.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível cancelar esta atividade.'),
          ),
        );
      }
    }
  }
}

final class TodayDashboard extends StatefulWidget {
  const TodayDashboard({
    required this.selectedDay,
    required this.activities,
    required this.occurrences,
    required this.timeZone,
    required this.onDaySelected,
    required this.onComplete,
    this.onVisibleMonthChanged,
    this.onManage,
    this.onAddRequested,
    this.onAlarmAccessRequested,
    super.key,
  });
  final DateTime selectedDay;
  final List<Activity> activities;
  final List<ActivityOccurrence> occurrences;
  final TimeZoneService timeZone;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<ActivityOccurrence> onComplete;
  final ValueChanged<DateTime>? onVisibleMonthChanged;
  final void Function(Activity, ActivityOccurrence)? onManage;
  final VoidCallback? onAddRequested;
  final VoidCallback? onAlarmAccessRequested;
  @override
  State<TodayDashboard> createState() => _TodayDashboardState();
}

final class _TodayDashboardState extends State<TodayDashboard> {
  bool _onlyPending = false;
  @override
  Widget build(BuildContext context) {
    final TodayDashboard(
      :selectedDay,
      :activities,
      :occurrences,
      :timeZone,
      :onDaySelected,
      :onComplete,
      :onVisibleMonthChanged,
      :onManage,
      :onAddRequested,
      :onAlarmAccessRequested,
    ) = widget;
    final theme = Theme.of(context);
    final sorted = [...occurrences]
      ..sort((a, b) => a.scheduledStartUtc.compareTo(b.scheduledStartUtc));
    final byId = {for (final a in activities) a.id: a};
    final completed = sorted
        .where((o) => o.status == OccurrenceStatus.completed)
        .length;
    final next = DailyTaskSequence.nextAction(sorted);
    final availableBlock = DailyTaskSequence.firstAvailable(sorted);
    final visible = _onlyPending
        ? sorted
              .where(
                (o) =>
                    o.status == OccurrenceStatus.scheduled ||
                    o.status == OccurrenceStatus.ringing ||
                    o.status == OccurrenceStatus.postponed,
              )
              .toList()
        : sorted;
    VoidCallback? manage(ActivityOccurrence o) {
      final a = byId[o.activityId];
      return a?.isActive == true && onManage != null
          ? () => onManage(a!, o)
          : null;
    }

    return Scaffold(
      bottomNavigationBar: onAddRequested == null
          ? null
          : ColoredBox(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.symmetric(
                  horizontal: RotinaSpacing.lg,
                  vertical: RotinaSpacing.sm,
                ),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: Tooltip(
                        message: 'Adicionar atividade',
                        child: FilledButton.icon(
                          onPressed: onAddRequested,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Nova atividade'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        bottom: onAddRequested == null,
        child: SingleChildScrollView(
          key: const ValueKey("daily-scroll"),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RotinaSpacing.lg,
                  vertical: RotinaSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandHeader(
                      onAlarmAccessRequested: onAlarmAccessRequested,
                    ),
                    const SizedBox(height: RotinaSpacing.lg),
                    _Welcome(selectedDay: selectedDay, total: sorted.length),
                    const SizedBox(height: RotinaSpacing.lg),
                    ContinuousMonthCalendar(
                      selectedDay: selectedDay,
                      onSelected: onDaySelected,
                      onVisibleMonthChanged: onVisibleMonthChanged,
                    ),
                    const SizedBox(height: RotinaSpacing.lg),
                    if (sorted.isEmpty)
                      const _EmptyRoutine()
                    else ...[
                      _NextActivityCard(
                        occurrence: next,
                        activity: next == null ? null : byId[next.activityId],
                        timeZone: timeZone,
                        onComplete: next == null
                            ? null
                            : () => onComplete(next),
                        onManage: next == null ? null : manage(next),
                      ),
                      const SizedBox(height: RotinaSpacing.md),
                      _ProgressCard(completed: completed, total: sorted.length),
                      const SizedBox(height: RotinaSpacing.lg),
                      Semantics(
                        header: true,
                        child: Text(
                          'Tarefas do dia',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: RotinaSpacing.md),
                      FilterChip(
                        label: const Text('Só pendentes'),
                        selected: _onlyPending,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onSelected: (selected) =>
                            setState(() => _onlyPending = selected),
                      ),
                      if (visible.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: RotinaSpacing.md,
                          ),
                          child: Text('Nenhuma pendência neste dia.'),
                        ),
                      for (final o in visible)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RotinaSpacing.sm,
                          ),
                          child: _TaskTile(
                            occurrence: o,
                            activity: byId[o.activityId],
                            timeZone: timeZone,
                            isNext: o.id == next?.id,
                            isLocked: DailyTaskSequence.isLocked(
                              occurrence: o,
                              available: availableBlock,
                            ),
                            onComplete: () => onComplete(o),
                            onManage: manage(o),
                          ),
                        ),
                    ],
                    const SizedBox(height: RotinaSpacing.md),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: const Text('Privacidade e suporte'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _BrandHeader extends StatelessWidget {
  const _BrandHeader({this.onAlarmAccessRequested});
  final VoidCallback? onAlarmAccessRequested;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: RotinaSpacing.md,
      runSpacing: RotinaSpacing.sm,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(RotinaSpacing.sm),
                decoration: BoxDecoration(
                  color: t.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(RotinaSpacing.md),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: t.colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(width: RotinaSpacing.sm),
            Flexible(child: Text('DayToDay', style: t.textTheme.titleLarge)),
          ],
        ),
        if (onAlarmAccessRequested != null)
          TextButton.icon(
            onPressed: onAlarmAccessRequested,
            icon: const Icon(Icons.notifications_none_rounded),
            label: const Text('Alarmes'),
          )
        else
          Text(
            'No seu ritmo',
            style: t.textTheme.labelLarge?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

final class _Welcome extends StatelessWidget {
  const _Welcome({required this.selectedDay, required this.total});
  final DateTime selectedDay;
  final int total;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final today = dateOnly(selectedDay) == dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            today ? 'Seu dia, no seu ritmo.' : 'Sua rotina neste dia',
            style: t.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: RotinaSpacing.xs),
        Text(
          '${_longDate(selectedDay)} · $total ${total == 1 ? 'atividade' : 'atividades'}',
          style: t.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

final class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.completed, required this.total});
  final int completed, total;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(RotinaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso · $completed de $total concluídas',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: RotinaSpacing.sm),
            LinearProgressIndicator(
              color: t.colorScheme.tertiary,
              backgroundColor: t.colorScheme.surface,
              value: total == 0 ? 0 : completed / total,
              minHeight: 6,
              borderRadius: BorderRadius.circular(RotinaSpacing.xs),
              semanticsLabel:
                  'Progresso da rotina, $completed de $total atividades concluídas',
              semanticsValue:
                  '${total == 0 ? 0 : (completed * 100 / total).round()}%',
            ),
          ],
        ),
      ),
    );
  }
}

final class _NextActivityCard extends StatelessWidget {
  const _NextActivityCard({
    required this.timeZone,
    this.occurrence,
    this.activity,
    this.onComplete,
    this.onManage,
  });
  final TimeZoneService timeZone;
  final ActivityOccurrence? occurrence;
  final Activity? activity;
  final VoidCallback? onComplete, onManage;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final colors = t.colorScheme;
    final o = occurrence;
    return Container(
      key: const ValueKey('next-activity-card'),
      padding: const EdgeInsets.all(RotinaSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(RotinaSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  o == null
                      ? 'Sem novos avisos neste dia'
                      : '${_relativeLabel(o.scheduledStartUtc)} · ${_time(timeZone, o.scheduledStartUtc)} · ${o.isReminder ? 'Lembrete' : '${o.estimatedDuration.inMinutes} min'}',
                  style: t.textTheme.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              if (onManage != null)
                IconButton(
                  onPressed: onManage,
                  tooltip: 'Editar ou cancelar atividade',
                  color: colors.onPrimaryContainer,
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
            ],
          ),
          const SizedBox(height: RotinaSpacing.sm),
          Text(
            activity?.title ?? 'Um passo de cada vez',
            style: t.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
          if (activity?.notes.isNotEmpty == true) ...[
            const SizedBox(height: RotinaSpacing.sm),
            Text(
              activity!.notes,
              style: t.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
          if (o == null) ...[
            const SizedBox(height: RotinaSpacing.sm),
            Text(
              'Confira suas atividades na lista abaixo ou planeje a próxima.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
          if (o != null) ...[
            const SizedBox(height: RotinaSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Concluir atividade'),
              ),
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
    required this.isLocked,
    required this.onComplete,
    this.onManage,
  });
  final ActivityOccurrence occurrence;
  final TimeZoneService timeZone;
  final Activity? activity;
  final bool isNext, isLocked;
  final VoidCallback onComplete;
  final VoidCallback? onManage;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;
    final completed = occurrence.status == OccurrenceStatus.completed;
    final skipped = occurrence.status == OccurrenceStatus.skipped;
    final cancelled = occurrence.status == OccurrenceStatus.cancelled;
    final terminal = completed || skipped || cancelled;
    final active = !terminal && isNext;
    final status = completed
        ? 'Concluída'
        : skipped
        ? 'Pulada'
        : cancelled
        ? 'Cancelada'
        : occurrence.acknowledgedAtUtc != null
        ? 'Aviso silenciado · Pendente'
        : isLocked
        ? 'Após concluir a anterior'
        : active
        ? 'Disponível agora'
        : 'Planejada';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RotinaSpacing.md),
        side: BorderSide(color: active ? c.primary : c.outlineVariant),
      ),
      child: InkWell(
        key: ValueKey('task-${occurrence.id}'),
        onTap: onManage,
        borderRadius: BorderRadius.circular(RotinaSpacing.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RotinaSpacing.sm,
            vertical: RotinaSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                button: !terminal && !isLocked,
                checked: completed,
                label: isLocked
                    ? 'Tarefa bloqueada até concluir a anterior'
                    : completed
                    ? 'Atividade concluída'
                    : skipped
                    ? 'Atividade pulada'
                    : cancelled
                    ? 'Atividade cancelada'
                    : 'Concluir atividade',
                child: IconButton(
                  key: ValueKey('complete-${occurrence.id}'),
                  onPressed: terminal || isLocked ? null : onComplete,
                  icon: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : isLocked
                        ? Icons.lock_outline_rounded
                        : skipped || cancelled
                        ? Icons.remove_circle_outline_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: terminal ? c.onSurfaceVariant : c.primary,
                  ),
                ),
              ),
              const SizedBox(width: RotinaSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: RotinaSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity?.title ?? 'Atividade',
                        style: t.textTheme.titleSmall?.copyWith(
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: RotinaSpacing.xs),
                      Text(
                        '${_time(timeZone, occurrence.scheduledStartUtc)} · ${occurrence.isReminder ? 'Lembrete' : '${occurrence.estimatedDuration.inMinutes} min'}',
                        style: t.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: RotinaSpacing.xs),
                      Text(
                        '$status · ${_priorityLabel(occurrence.priority)}',
                        style: t.textTheme.labelMedium?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onManage != null)
                IconButton(
                  onPressed: onManage,
                  tooltip: 'Editar ou cancelar atividade',
                  icon: const Icon(Icons.more_vert_rounded),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(RotinaSpacing.sm),
                  child: Icon(
                    _priorityIcon(occurrence.priority),
                    color: c.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(RotinaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.event_note_rounded,
              color: t.colorScheme.primary,
              size: 36,
            ),
            const SizedBox(height: RotinaSpacing.md),
            Text(
              'Seu dia começa com um passo',
              style: t.textTheme.headlineSmall,
            ),
            const SizedBox(height: RotinaSpacing.sm),
            Text(
              'Toque em Nova atividade para escolher um horário e organizar sua rotina. Tudo fica salvo neste aparelho.',
              style: t.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: CircularProgressIndicator(semanticsLabel: 'Abrindo sua rotina'),
    ),
  );
}

final class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RotinaSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: t.colorScheme.primary,
                    size: 48,
                  ),
                  const SizedBox(height: RotinaSpacing.md),
                  Text(
                    'Não conseguimos abrir a rotina.',
                    style: t.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: RotinaSpacing.sm),
                  const Text(
                    'Houve um problema ao ler os dados deste aparelho. Tente novamente.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: RotinaSpacing.lg),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

String _priorityLabel(ActivityPriority priority) => switch (priority) {
  ActivityPriority.high => "Importante",
  ActivityPriority.normal => "Normal",
  ActivityPriority.low => "Leve",
};

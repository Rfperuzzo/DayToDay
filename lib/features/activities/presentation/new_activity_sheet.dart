import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../../alarms/domain/alarm_permission_gateway.dart';
import '../application/activity_creator.dart';
import '../application/schedule_availability.dart';
import '../domain/activity.dart';
import '../domain/activity_recurrence_preset.dart';
import '../domain/recurrence_rule.dart';
import 'activity_recurrence_selector.dart';

final class NewActivityOutcome {
  const NewActivityOutcome({
    required this.creation,
    required this.alarmCapabilities,
    this.alarmsRequested = true,
  });

  final ActivityCreationResult creation;
  final AlarmCapabilities? alarmCapabilities;
  final bool alarmsRequested;

  bool get fullyReady =>
      !alarmsRequested ||
      (creation.alarmsSynchronized &&
          (alarmCapabilities?.fullyOperational ?? false));
}

final class NewActivitySheet extends StatefulWidget {
  const NewActivitySheet({
    required this.initialDay,
    required this.timeZone,
    required this.permissions,
    required this.onCreate,
    this.clock = const SystemClock(),
    super.key,
  });

  final DateTime initialDay;
  final TimeZoneService timeZone;
  final AlarmPermissionGateway permissions;
  final Future<ActivityCreationResult> Function(ActivityDraft draft) onCreate;
  final Clock clock;

  @override
  State<NewActivitySheet> createState() => _NewActivitySheetState();
}

final class _NewActivitySheetState extends State<NewActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _day;
  late TimeOfDay _time;
  late TimeOfDay _endTime;
  int _endDayOffset = 0;
  bool _notifyAtStart = true;
  bool _notifyAtEnd = false;
  String? _timingError;
  bool _reserveTime = false;
  Set<int> _customWeekdays = {DateTime.monday};
  var _priority = ActivityPriority.normal;
  var _recurrence = ActivityRecurrencePreset.once;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final now = widget.timeZone.toLocal(widget.clock.nowUtc());
    final today = DateUtils.dateOnly(now);
    final initial = DateUtils.dateOnly(widget.initialDay);
    _day = initial.isBefore(today) ? today : initial;
    final suggested = now.add(const Duration(minutes: 30));
    if (_day == today && DateUtils.dateOnly(suggested).isAfter(today)) {
      _day = DateUtils.dateOnly(suggested);
    }
    _time = _initialTime(_day, today, suggested);
    final endMinutes = _time.hour * 60 + _time.minute + 30;
    _endTime = TimeOfDay(
      hour: (endMinutes ~/ 60) % 24,
      minute: endMinutes % 60,
    );
    _endDayOffset = endMinutes ~/ 1440;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AbsorbPointer(
        absorbing: _saving,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: RotinaColors.outline,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Nova atividade',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Fechar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Escolha a atividade e o horário. Reserve tempo se precisar.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'O que você vai fazer?'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome da atividade',
                        hintText: 'Ex.: Beber água',
                        prefixIcon: Icon(Icons.checklist_rounded),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Digite o nome da atividade.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                        hintText: 'Local ou algo que você quer lembrar',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(label: _reserveTime ? 'Início' : 'Quando?'),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final day = _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: _shortDate(_day),
                          onTap: _pickDay,
                        );
                        final time = _PickerTile(
                          icon: Icons.schedule_rounded,
                          label: _reserveTime
                              ? 'Início · ${_time.format(context)}'
                              : _time.format(context),
                          onTap: _pickTime,
                        );
                        if (constraints.maxWidth < 360 &&
                            MediaQuery.textScalerOf(context).scale(16) > 20) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              day,
                              const SizedBox(height: RotinaSpacing.sm),
                              time,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: day),
                            const SizedBox(width: RotinaSpacing.sm),
                            Expanded(child: time),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reservar tempo na agenda'),
                      subtitle: Text(
                        _reserveTime
                            ? 'Reserva um intervalo e evita sobreposição com outros blocos.'
                            : 'Lembrete: avisa no horário, sem reservar sua agenda.',
                      ),
                      value: _reserveTime,
                      onChanged: (value) =>
                          setState(() => _reserveTime = value),
                    ),
                    if (_reserveTime) ...[
                      BlockTimingFields(
                        endTime: _endTime,
                        endDayOffset: _endDayOffset,
                        duration: _blockDuration,
                        notifyAtStart: _notifyAtStart,
                        notifyAtEnd: _notifyAtEnd,
                        error: _timingError,
                        onEndTimeChanged: (value) => setState(() {
                          _endTime = value;
                          _timingError = null;
                        }),
                        onNextDayChanged: (value) => setState(() {
                          _endDayOffset = value ? 1 : 0;
                          _timingError = null;
                        }),
                        onStartAlertChanged: (value) =>
                            setState(() => _notifyAtStart = value),
                        onEndAlertChanged: (value) =>
                            setState(() => _notifyAtEnd = value),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _SectionLabel(label: 'Repetição'),
                    const SizedBox(height: 8),
                    ActivityRecurrenceSelector(
                      value: _recurrence,
                      customWeekdays: _customWeekdays,
                      onWeekdaysChanged: (days) =>
                          setState(() => _customWeekdays = days),
                      onChanged: (value) => setState(() => _recurrence = value),
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(label: 'Prioridade'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PriorityChip(
                          label: 'Leve',
                          icon: Icons.spa_rounded,
                          selected: _priority == ActivityPriority.low,
                          onSelected: () =>
                              setState(() => _priority = ActivityPriority.low),
                        ),
                        _PriorityChip(
                          label: 'Normal',
                          icon: Icons.favorite_rounded,
                          selected: _priority == ActivityPriority.normal,
                          onSelected: () => setState(
                            () => _priority = ActivityPriority.normal,
                          ),
                        ),
                        _PriorityChip(
                          label: 'Importante',
                          icon: Icons.bolt_rounded,
                          selected: _priority == ActivityPriority.high,
                          onSelected: () =>
                              setState(() => _priority = ActivityPriority.high),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: RotinaColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.alarm_rounded,
                            color: RotinaColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _hasAlarms
                                  ? 'Cada aviso toca uma vez. Parar o aviso não conclui a atividade. O Android pode exigir acessos especiais.'
                                  : 'Este bloco ficará na agenda sem avisos sonoros. Você pode concluí-lo pela sua rotina.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_alarm_rounded),
                      label: Text(
                        _saving
                            ? 'Salvando…'
                            : _hasAlarms
                            ? 'Salvar e preparar alarme'
                            : 'Salvar atividade',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
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

  TimeOfDay _initialTime(DateTime day, DateTime today, DateTime suggested) {
    if (day != today) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    final roundedMinute = ((suggested.minute + 4) ~/ 5) * 5;
    return TimeOfDay(
      hour: (suggested.hour + roundedMinute ~/ 60) % 24,
      minute: roundedMinute % 60,
    );
  }

  Future<void> _pickDay() async {
    final now = DateUtils.dateOnly(
      widget.timeZone.toLocal(widget.clock.nowUtc()),
    );
    final limit = DateTime(now.year + 2, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: now,
      lastDate: _day.isAfter(limit) ? _day : limit,
      helpText: 'Escolha o dia',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (mounted && selected != null) {
      setState(() {
        _day = DateUtils.dateOnly(selected);
        _timingError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      initialTime: _time,
      helpText: _reserveTime ? 'Horário inicial' : 'Horário',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (mounted && selected != null) {
      setState(() {
        _time = selected;
        _timingError = null;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_reserveTime && _blockDuration <= Duration.zero) {
      setState(
        () => _timingError =
            'Escolha um horário final depois do início. Se necessário, marque o dia seguinte.',
      );
      return;
    }
    final localComponents = DateTime(
      _day.year,
      _day.month,
      _day.day,
      _time.hour,
      _time.minute,
    );
    final scheduledAtUtc = widget.timeZone.localComponentsToUtc(
      localComponents,
    );
    if (_recurrence == ActivityRecurrencePreset.once &&
        !scheduledAtUtc.isAfter(widget.clock.nowUtc())) {
      _showPassedTimeMessage();
      return;
    }

    setState(() => _saving = true);
    try {
      final capabilities = _hasAlarms ? await _ensureAlarmAccess() : null;
      if (_recurrence == ActivityRecurrencePreset.once &&
          !scheduledAtUtc.isAfter(widget.clock.nowUtc())) {
        if (mounted) {
          setState(() => _saving = false);
          _showPassedTimeMessage(
            'O horário passou enquanto os acessos eram liberados. Escolha um novo horário.',
          );
        }
        return;
      }
      final recurrence = switch (_recurrence) {
        ActivityRecurrencePreset.custom => WeeklyRecurrence(
          weekdays: _customWeekdays,
          hour: _time.hour,
          minute: _time.minute,
        ),
        ActivityRecurrencePreset.once => OneOffRecurrence(scheduledAtUtc),
        ActivityRecurrencePreset.daily => WeeklyRecurrence.daily(
          hour: _time.hour,
          minute: _time.minute,
        ),
        ActivityRecurrencePreset.weekdays => WeeklyRecurrence(
          weekdays: const {
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          },
          hour: _time.hour,
          minute: _time.minute,
        ),
      };
      final creation = await widget.onCreate(
        ActivityDraft(
          title: _titleController.text,
          notes: _notesController.text,
          kind: _reserveTime ? ActivityKind.timeBlock : ActivityKind.reminder,
          estimatedDuration: _reserveTime ? _blockDuration : Duration.zero,
          notifyAtStart: _reserveTime ? _notifyAtStart : true,
          notifyAtEnd: _reserveTime ? _notifyAtEnd : false,
          usesBoundaryAlarms: _reserveTime,
          priority: _priority,
          recurrence: recurrence,
        ),
      );
      HapticFeedback.lightImpact().ignore();
      if (mounted) {
        Navigator.pop(
          context,
          NewActivityOutcome(
            creation: creation,
            alarmCapabilities: capabilities,
            alarmsRequested: _hasAlarms,
          ),
        );
      }
    } on ScheduleConflictException catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        final next = widget.timeZone.toLocal(error.nextAvailableUtc);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Esse intervalo está ocupado. Próximo horário livre: ${_twoDigits(next.hour)}:${_twoDigits(next.minute)}.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível salvar a atividade. Tente novamente.',
            ),
          ),
        );
      }
    }
  }

  void _showPassedTimeMessage([
    String message = 'Escolha um horário que ainda não passou.',
  ]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _hasAlarms => !_reserveTime || _notifyAtStart || _notifyAtEnd;

  Duration get _blockDuration => blockDurationBetween(
    day: _day,
    start: _time,
    end: _endTime,
    endDayOffset: _endDayOffset,
    timeZone: widget.timeZone,
  );

  Future<AlarmCapabilities?> _ensureAlarmAccess() async {
    AlarmCapabilities? capabilities;
    try {
      capabilities = await widget.permissions.check();
    } catch (_) {
      return null;
    }
    if (capabilities.fullyOperational || !mounted) {
      return capabilities;
    }
    final activate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active_rounded),
        title: const Text('Liberar o alarme forte?'),
        content: const Text(
          'Para tocar com a tela bloqueada e durante o Não Perturbe, o Android precisa liberar notificações, tela cheia e acesso especial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ativar acesso'),
          ),
        ],
      ),
    );
    if (activate != true) {
      return capabilities;
    }
    try {
      return await widget.permissions.requestRequiredAccess();
    } catch (_) {
      return capabilities;
    }
  }
}

/// Shared presentation of an explicitly chosen block end and its alert options.
final class BlockTimingFields extends StatelessWidget {
  const BlockTimingFields({
    required this.endTime,
    required this.endDayOffset,
    required this.duration,
    required this.notifyAtStart,
    required this.notifyAtEnd,
    required this.onEndTimeChanged,
    required this.onNextDayChanged,
    required this.onStartAlertChanged,
    required this.onEndAlertChanged,
    this.error,
    super.key,
  });

  final TimeOfDay endTime;
  final int endDayOffset;
  final Duration duration;
  final bool notifyAtStart, notifyAtEnd;
  final ValueChanged<TimeOfDay> onEndTimeChanged;
  final ValueChanged<bool> onNextDayChanged,
      onStartAlertChanged,
      onEndAlertChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          key: const ValueKey('block-end-time'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule_rounded),
          title: const Text('Horário final'),
          subtitle: Text(endTime.format(context)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final selected = await showTimePicker(
              context: context,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
              initialTime: endTime,
              helpText: 'Horário final',
              cancelText: 'Cancelar',
              confirmText: 'Escolher',
            );
            if (context.mounted && selected != null) onEndTimeChanged(selected);
          },
        ),
        CheckboxListTile(
          key: const ValueKey('block-next-day'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            endDayOffset > 1
                ? 'Termina $endDayOffset dias depois (duração existente)'
                : 'Termina no dia seguinte',
          ),
          subtitle: endDayOffset > 1
              ? const Text(
                  'O intervalo original será mantido. Ao alterar o término, escolha hoje ou o dia seguinte.',
                )
              : null,
          value: endDayOffset > 0,
          onChanged: (value) => onNextDayChanged(value ?? false),
        ),
        Text(
          duration > Duration.zero
              ? 'Duração: ${_durationLabel(duration)}'
              : 'O horário final deve ser depois do início.',
          key: const ValueKey('block-duration-summary'),
          style: theme.textTheme.bodyMedium,
        ),
        if (error != null) ...[
          const SizedBox(height: RotinaSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
        const SizedBox(height: RotinaSpacing.md),
        Text('Avisos do bloco', style: theme.textTheme.titleSmall),
        SwitchListTile.adaptive(
          key: const ValueKey('block-notify-start'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Avisar no início'),
          value: notifyAtStart,
          onChanged: onStartAlertChanged,
        ),
        SwitchListTile.adaptive(
          key: const ValueKey('block-notify-end'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Avisar no final'),
          value: notifyAtEnd,
          onChanged: onEndAlertChanged,
        ),
        Text(
          'Os avisos não marcam a atividade como concluída. Quando o final coincidir com o início de outro bloco com aviso, você receberá um único aviso de troca.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

Duration blockDurationBetween({
  required DateTime day,
  required TimeOfDay start,
  required TimeOfDay end,
  required int endDayOffset,
  required TimeZoneService timeZone,
}) => timeZone
    .localComponentsToUtc(
      DateTime(
        day.year,
        day.month,
        day.day + endDayOffset,
        end.hour,
        end.minute,
      ),
    )
    .difference(
      timeZone.localComponentsToUtc(
        DateTime(day.year, day.month, day.day, start.hour, start.minute),
      ),
    );

String _durationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$minutes min';
  return remainder == 0 ? '$hours h' : '$hours h $remainder min';
}

final class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: RotinaColors.text),
  );
}

final class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: RotinaColors.surfaceSoft,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(
          children: [
            Icon(icon, color: RotinaColors.primary, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,

                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    avatar: Icon(
      icon,
      size: 18,
      color: selected ? Colors.white : RotinaColors.primary,
    ),
    label: Text(label),
    selected: selected,
    selectedColor: RotinaColors.primary,
    labelStyle: TextStyle(
      color: selected ? Colors.white : RotinaColors.text,
      fontWeight: FontWeight.w700,
    ),
    onSelected: (_) => onSelected(),
  );
}

String _shortDate(DateTime date) {
  const months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

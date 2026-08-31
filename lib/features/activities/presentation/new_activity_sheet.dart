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

final class NewActivityOutcome {
  const NewActivityOutcome({
    required this.creation,
    required this.alarmCapabilities,
  });

  final ActivityCreationResult creation;
  final AlarmCapabilities? alarmCapabilities;

  bool get fullyReady =>
      creation.alarmsSynchronized &&
      (alarmCapabilities?.fullyOperational ?? false);
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
  var _durationMinutes = 30;
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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Conte o que vai acontecer; o app cuida do horário e do alarme.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'O que a Andriele vai fazer?'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Ex.: Treino de pernas',
                    prefixIcon: Icon(Icons.auto_awesome_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Digite o nome da atividade.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Local ou observação (opcional)',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Quando?'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: _shortDate(_day),
                        onTap: _pickDay,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.schedule_rounded,
                        label: _time.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Duração'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final minutes in const [15, 30, 45, 60, 90])
                      ChoiceChip(
                        label: Text('$minutes min'),
                        selected: _durationMinutes == minutes,
                        onSelected: (_) =>
                            setState(() => _durationMinutes = minutes),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Repetição'),
                const SizedBox(height: 8),
                SegmentedButton<ActivityRecurrencePreset>(
                  segments: const [
                    ButtonSegment(
                      value: ActivityRecurrencePreset.once,
                      label: Text('Uma vez'),
                    ),
                    ButtonSegment(
                      value: ActivityRecurrencePreset.daily,
                      label: Text('Todo dia'),
                    ),
                    ButtonSegment(
                      value: ActivityRecurrencePreset.weekdays,
                      label: Text('Seg–sex'),
                    ),
                  ],
                  selected: {_recurrence},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) =>
                      setState(() => _recurrence = value.single),
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
                      onSelected: () =>
                          setState(() => _priority = ActivityPriority.normal),
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
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.alarm_rounded, color: RotinaColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'O alarme principal toca em loop e vibra até você responder. O Android pode exigir acessos especiais.',
                          style: TextStyle(
                            color: RotinaColors.text,
                            height: 1.4,
                          ),
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
                    _saving ? 'Salvando…' : 'Salvar e preparar alarme',
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
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: now,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      helpText: 'Escolha o dia',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (selected != null) {
      setState(() => _day = DateUtils.dateOnly(selected));
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Escolha o horário',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (selected != null) {
      setState(() => _time = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
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
      final capabilities = await _ensureAlarmAccess();
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
          estimatedDuration: Duration(minutes: _durationMinutes),
          priority: _priority,
          recurrence: recurrence,
        ),
      );
      await HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pop(
          context,
          NewActivityOutcome(
            creation: creation,
            alarmCapabilities: capabilities,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

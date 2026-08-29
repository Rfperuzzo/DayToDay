import 'package:flutter/material.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/time_zone_service.dart';
import '../application/activity_manager.dart';
import '../domain/activity.dart';
import '../domain/activity_occurrence.dart';
import '../domain/activity_recurrence_preset.dart';
import '../domain/recurrence_rule.dart';

enum ActivityOption { complete, edit, subtasks, cancel }

final class ActivityOptionsSheet extends StatelessWidget {
  const ActivityOptionsSheet({
    required this.activity,
    required this.occurrence,
    required this.timeZone,
    this.showComplete = false,
    super.key,
  });

  final Activity activity;
  final ActivityOccurrence occurrence;
  final TimeZoneService timeZone;
  final bool showComplete;

  @override
  Widget build(BuildContext context) {
    final local = timeZone.toLocal(occurrence.scheduledStartUtc);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_shortDate(local)} • ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RotinaColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (showComplete) ...[
              _OptionTile(
                icon: Icons.check_circle_rounded,
                title: 'Concluir tarefa',
                subtitle: 'Registra a conclusão e libera a próxima tarefa.',
                onTap: () => Navigator.pop(context, ActivityOption.complete),
              ),
              const SizedBox(height: 10),
            ],
            _OptionTile(
              icon: Icons.edit_calendar_rounded,
              title: 'Editar nome ou horário',
              subtitle: 'Atualiza esta atividade e as próximas repetições.',
              onTap: () => Navigator.pop(context, ActivityOption.edit),
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.account_tree_outlined,
              title: 'Subtarefas',
              subtitle: 'Divida esta atividade em etapas relacionadas.',
              onTap: () => Navigator.pop(context, ActivityOption.subtasks),
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.cancel_outlined,
              title: 'Cancelar atividade',
              subtitle: 'Desativa a atividade e os próximos alarmes.',
              destructive: true,
              onTap: () => Navigator.pop(context, ActivityOption.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

final class EditActivitySheet extends StatefulWidget {
  const EditActivitySheet({
    required this.activity,
    required this.occurrence,
    required this.timeZone,
    this.clock = const SystemClock(),
    super.key,
  });

  final Activity activity;
  final ActivityOccurrence occurrence;
  final TimeZoneService timeZone;
  final Clock clock;

  @override
  State<EditActivitySheet> createState() => _EditActivitySheetState();
}

final class _EditActivitySheetState extends State<EditActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late TimeOfDay _time;
  late ActivityRecurrencePreset _recurrence;
  late int _durationMinutes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity.title);
    final local = widget.timeZone.toLocal(widget.occurrence.scheduledStartUtc);
    _time = TimeOfDay.fromDateTime(local);
    _recurrence = _presetFor(widget.activity.recurrence);
    _durationMinutes = widget.activity.estimatedDuration.inMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
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
              mainAxisSize: MainAxisSize.min,
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
                        'Editar atividade',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Fechar',
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'O novo nome e horário valerão para esta atividade e as próximas repetições.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome da atividade',
                    prefixIcon: Icon(Icons.edit_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Digite o nome da atividade.'
                      : null,
                ),
                const SizedBox(height: 16),
                Material(
                  color: RotinaColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                  child: ListTile(
                    onTap: _pickTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    leading: const Icon(
                      Icons.schedule_rounded,
                      color: RotinaColors.primary,
                    ),
                    title: const Text('Horário'),
                    subtitle: Text(_time.format(context)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duração',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: RotinaColors.text),
                ),
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
                const SizedBox(height: 16),
                Text(
                  'Repetição',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: RotinaColors.text),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ActivityRecurrencePreset>(
                    segments: const [
                      ButtonSegment(
                        value: ActivityRecurrencePreset.once,
                        label: Text('Só este dia'),
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
                ),
                const SizedBox(height: 16),
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
                          'Os alarmes antigos serão substituídos automaticamente.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Salvar alterações'),
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

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Novo horário',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (selected != null) {
      setState(() => _time = selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_recurrence == ActivityRecurrencePreset.once) {
      final currentLocal = widget.timeZone.toLocal(
        widget.occurrence.scheduledStartUtc,
      );
      final editedUtc = widget.timeZone.localComponentsToUtc(
        DateTime(
          currentLocal.year,
          currentLocal.month,
          currentLocal.day,
          _time.hour,
          _time.minute,
        ),
      );
      if (!editedUtc.isAfter(widget.clock.nowUtc())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escolha um horário que ainda não passou.'),
          ),
        );
        return;
      }
    }
    Navigator.pop(
      context,
      ActivityEditDraft(
        title: _titleController.text,
        hour: _time.hour,
        minute: _time.minute,
        recurrence: _recurrence,
        estimatedDuration: Duration(minutes: _durationMinutes),
      ),
    );
  }
}

final class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? RotinaColors.danger : RotinaColors.primary;
    return Material(
      color: destructive
          ? RotinaColors.danger.withValues(alpha: 0.08)
          : RotinaColors.surfaceSoft,
      borderRadius: BorderRadius.circular(22),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
      ),
    );
  }
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

ActivityRecurrencePreset _presetFor(RecurrenceRule recurrence) {
  if (recurrence is OneOffRecurrence) {
    return ActivityRecurrencePreset.once;
  }
  final weekly = recurrence as WeeklyRecurrence;
  if (weekly.weekdays.length == DateTime.daysPerWeek) {
    return ActivityRecurrencePreset.daily;
  }
  return ActivityRecurrencePreset.weekdays;
}

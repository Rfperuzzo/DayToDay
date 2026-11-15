import 'package:flutter/material.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../domain/activity_recurrence_preset.dart';

/// Equivalent recurrence choices reflow with text instead of clipping a segment.
final class ActivityRecurrenceSelector extends StatelessWidget {
  const ActivityRecurrenceSelector({
    required this.value,
    required this.onChanged,
    this.customWeekdays = const {DateTime.monday},
    this.onWeekdaysChanged,
    super.key,
  });

  final Set<int> customWeekdays;
  final ValueChanged<Set<int>>? onWeekdaysChanged;
  final ActivityRecurrencePreset value;
  final ValueChanged<ActivityRecurrencePreset> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: RotinaSpacing.sm,
    runSpacing: RotinaSpacing.sm,
    children: [
      for (final option in const [
        (ActivityRecurrencePreset.once, 'Uma vez'),
        (ActivityRecurrencePreset.daily, 'Todo dia'),
        (ActivityRecurrencePreset.weekdays, 'Seg–sex'),
        (ActivityRecurrencePreset.custom, 'Dias específicos'),
      ])
        ChoiceChip(
          label: Text(option.$2),
          selected: value == option.$1,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (_) => onChanged(option.$1),
        ),
      if (value == ActivityRecurrencePreset.custom) ...[
        const SizedBox(
          width: double.infinity,
          child: Text('Repetir em pelo menos um dia:'),
        ),
        for (final day in const [
          (1, 'Seg', 'Segunda-feira'),
          (2, 'Ter', 'Terça-feira'),
          (3, 'Qua', 'Quarta-feira'),
          (4, 'Qui', 'Quinta-feira'),
          (5, 'Sex', 'Sexta-feira'),
          (6, 'Sáb', 'Sábado'),
          (7, 'Dom', 'Domingo'),
        ])
          FilterChip(
            label: Text(day.$2),
            tooltip: day.$3,
            selected: customWeekdays.contains(day.$1),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            onSelected: onWeekdaysChanged == null
                ? null
                : (selected) {
                    final next = {...customWeekdays};
                    selected ? next.add(day.$1) : next.remove(day.$1);
                    if (next.isNotEmpty) onWeekdaysChanged!(next);
                  },
          ),
      ],
    ],
  );
}

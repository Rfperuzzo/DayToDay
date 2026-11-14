import 'package:flutter/material.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../domain/activity_recurrence_preset.dart';

/// Equivalent recurrence choices reflow with text instead of clipping a segment.
final class ActivityRecurrenceSelector extends StatelessWidget {
  const ActivityRecurrenceSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

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
      ])
        ChoiceChip(
          label: Text(option.$2),
          selected: value == option.$1,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: (_) => onChanged(option.$1),
        ),
    ],
  );
}

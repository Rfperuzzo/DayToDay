import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/presentation/rotina_theme.dart';
import '../../dashboard/application/day_providers.dart';
import '../domain/activity.dart';
import '../domain/subtask.dart';

final class SubtasksSheet extends ConsumerStatefulWidget {
  const SubtasksSheet({required this.activity, super.key});

  final Activity activity;

  @override
  ConsumerState<SubtasksSheet> createState() => _SubtasksSheetState();
}

final class _SubtasksSheetState extends ConsumerState<SubtasksSheet> {
  final _controller = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtasks = ref.watch(subtasksProvider(widget.activity.id));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtarefas',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.activity.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
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
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(),
                        decoration: const InputDecoration(
                          hintText: 'Adicionar uma etapa',
                          prefixIcon: Icon(Icons.playlist_add_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _saving ? null : _add,
                      tooltip: 'Adicionar subtarefa',
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: subtasks.when(
                    data: (items) => _SubtaskList(
                      items: items,
                      onChanged: _setCompleted,
                      onDelete: _delete,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Center(
                      child: Text('Não foi possível abrir as subtarefas.'),
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

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _saving) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(subtaskManagerProvider)
          .add(activityId: widget.activity.id, title: title);
      _controller.clear();
      await HapticFeedback.lightImpact();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível adicionar a etapa.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _setCompleted(Subtask subtask, bool completed) async {
    try {
      await ref.read(subtaskManagerProvider).setCompleted(subtask, completed);
      await HapticFeedback.selectionClick();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar a etapa.')),
        );
      }
    }
  }

  Future<void> _delete(Subtask subtask) async {
    try {
      await ref.read(subtaskManagerProvider).delete(subtask);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível remover a etapa.')),
        );
      }
    }
  }
}

final class _SubtaskList extends StatelessWidget {
  const _SubtaskList({
    required this.items,
    required this.onChanged,
    required this.onDelete,
  });

  final List<Subtask> items;
  final void Function(Subtask, bool) onChanged;
  final ValueChanged<Subtask> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Divida a atividade em passos pequenos e possíveis.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final completed = items.where((item) => item.isCompleted).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$completed de ${items.length} etapas concluídas',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = items[index];
              return Material(
                color: RotinaColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
                child: CheckboxListTile(
                  value: item.isCompleted,
                  onChanged: (value) => onChanged(item, value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  secondary: IconButton(
                    onPressed: () => onDelete(item),
                    tooltip: 'Remover subtarefa',
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

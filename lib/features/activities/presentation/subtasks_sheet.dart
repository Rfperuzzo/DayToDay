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
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: SafeArea(
            top: false,
            child: CustomScrollView(
              key: const ValueKey('subtasks-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(RotinaSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Subtarefas',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: RotinaSpacing.xs),
                                Text(
                                  widget.activity.title,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            tooltip: 'Fechar',
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: RotinaSpacing.lg),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !_saving,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _add(),
                              decoration: const InputDecoration(
                                labelText: 'Nova subtarefa',
                                hintText: 'Adicionar uma etapa',
                                prefixIcon: Icon(Icons.playlist_add_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: RotinaSpacing.sm),
                          IconButton.filled(
                            onPressed: _saving ? null : _add,
                            tooltip: 'Adicionar subtarefa',
                            icon: _saving
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
                ...subtasks.when(
                  data: (items) => [
                    if (items.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(RotinaSpacing.lg),
                          child: Text(
                            'Divida a atividade em passos pequenos e possíveis.',
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RotinaSpacing.lg,
                          ),
                          child: Text(
                            '${items.where((i) => i.isCompleted).length} de ${items.length} etapas concluídas',
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(RotinaSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = items[index];
                            return Card(
                              child: CheckboxListTile(
                                value: item.isCompleted,
                                onChanged: (value) =>
                                    _setCompleted(item, value ?? false),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  item.title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                secondary: IconButton(
                                  onPressed: () => _delete(item),
                                  tooltip: 'Remover subtarefa',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: items.length),
                        ),
                      ),
                    ],
                  ],
                  loading: () => [
                    const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Abrindo subtarefas',
                        ),
                      ),
                    ),
                  ],
                  error: (error, stack) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(RotinaSpacing.lg),
                        child: Column(
                          children: [
                            const Text('Não foi possível abrir as subtarefas.'),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(
                                subtasksProvider(widget.activity.id),
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      if (!mounted) return;
      _controller.clear();
      HapticFeedback.lightImpact().ignore();
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
      HapticFeedback.selectionClick().ignore();
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

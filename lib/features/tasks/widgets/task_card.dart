import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_item.dart';
import '../../../data/models/sub_task_item.dart';
import 'subtask_checklist.dart';

/// Card de tarefa na lista.
///
/// Suporta:
/// - Swipe-to-delete (via [Dismissible] + [onDelete])
/// - Indicador visual de atraso (fundo/cor) quando a data agendada
///   é anterior a hoje e a tarefa não está concluída.
/// - Checkbox para tarefas genéricas; ícone de ação para os demais tipos.
class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  /// Subtarefas para exibir no card (com checkboxes interativos).
  final List<SubTaskItem>? subtasks;

  /// Callback quando o usuário alterna uma subtarefa no card.
  final ValueChanged<int>? onToggleSubtask;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
    this.subtasks,
    this.onToggleSubtask,
  });

  bool get _isOverdue => task.isOverdue;

  IconData get _typeIcon {
    switch (task.type) {
      case TaskType.generic:
        return Icons.check_circle_outline;
      case TaskType.pomodoroStudy:
        return Icons.school_outlined;
      case TaskType.timedExercise:
        return Icons.timer_outlined;
      case TaskType.repsExercise:
        return Icons.fitness_center_outlined;
    }
  }

  String _typeLabel() {
    switch (task.type) {
      case TaskType.generic:
        return 'Genérica';
      case TaskType.pomodoroStudy:
        final d = task.durationMinutes ?? 25;
        return 'Pomodoro $d min';
      case TaskType.timedExercise:
        final d = task.durationSeconds ?? 60;
        return 'Timer ${d}s';
      case TaskType.repsExercise:
        final r = task.targetReps ?? 10;
        final s = task.targetSets ?? 3;
        return '$r reps x $s séries';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Retorna true para permitir a animação de dismiss;
      // a deleção efetiva ocorre em onDismissed.
      confirmDismiss: (_) async => true,
      onDismissed: (_) {
        onDelete?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color:
            _isOverdue ? theme.colorScheme.error.withValues(alpha: 0.08) : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Checkbox para qualquer tipo
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onToggleComplete?.call(),
                    ),
                    const SizedBox(width: 4),
                    // Ícone do tipo (apenas informativo)
                    Icon(
                      _typeIcon,
                      size: 18,
                      color: task.isCompleted
                          ? theme.colorScheme.primary
                          : (_isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)),
                    ),
                    const SizedBox(width: 8),

                    // Corpo do card
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _typeLabel(),
                                style: theme.textTheme.bodySmall,
                              ),
                              if (_isOverdue) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'Atrasada',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Data/horário + pontos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (task.scheduledTime != null)
                          Text(
                            DateFormat('HH:mm').format(task.scheduledTime!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (task.scheduledDate != null)
                          Text(
                            DateFormat('dd/MM').format(task.scheduledDate!),
                            style: theme.textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${task.rewardPoints}pts',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Subtarefas (checklist) — só leitura no card
                SubtaskChecklist(
                  parentTaskId: task.id,
                  showAddField: false,
                  showTypeSelector: false,
                  initialSubtasks: subtasks,
                  onToggleSubtask: onToggleSubtask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

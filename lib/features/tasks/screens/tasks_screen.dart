import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/task_item.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';
import '../widgets/timer_widget.dart';
import '../widgets/rep_counter_widget.dart';

/// Tela principal de tarefas.
///
/// Exibe as tarefas do dia corrente divididas em duas seções:
/// pendentes (não concluídas) e concluídas. Um FAB abre o
/// formulário de nova tarefa ([TaskForm]).
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  /// Abre o formulário de criação/edição de tarefa.
  static void openForm(BuildContext context, {TaskItem? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskForm(task: task),
      ),
    );
  }

  void _openEdit(BuildContext context, TaskItem task) {
    openForm(context, task: task);
  }

  void _showTimerSheet(BuildContext context, TaskItem task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TimerWidget(
        durationMinutes: task.type == TaskType.pomodoroStudy
            ? (task.durationMinutes ?? AppConstants.defaultPomodoroFocusMinutes)
            : 0,
        durationSeconds: task.type == TaskType.timedExercise
            ? (task.durationSeconds ?? AppConstants.defaultTimedExerciseSeconds)
            : null,
        breakDurationMinutes: task.type == TaskType.pomodoroStudy
            ? AppConstants.defaultPomodoroBreakMinutes
            : 0,
        onFinish: () async {
          Navigator.of(ctx).pop();
          try {
            await context.read<TaskController>().completeTask(task.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tarefa concluída!')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao concluir: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showRepsSheet(BuildContext context, TaskItem task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => RepCounterWidget(
        targetReps: task.targetReps ?? AppConstants.defaultRepsTarget,
        targetSets: task.targetSets ?? AppConstants.defaultSetsTarget,
        onComplete: () async {
          Navigator.of(ctx).pop();
          try {
            await context.read<TaskController>().completeTask(task.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${task.title} concluída!')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao concluir: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onToggleComplete(BuildContext context, TaskItem task) async {
    final controller = context.read<TaskController>();
    try {
      if (task.isCompleted) {
        await controller.uncompleteTask(task.id);
      } else {
        await controller.completeTask(task.id);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alternar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onCardTap(BuildContext context, TaskItem task) {
    if (task.isCompleted) {
      _openEdit(context, task);
      return;
    }

    switch (task.type) {
      case TaskType.generic:
        _openEdit(context, task);
      case TaskType.pomodoroStudy:
      case TaskType.timedExercise:
        _showTimerSheet(context, task);
      case TaskType.repsExercise:
        _showRepsSheet(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        final pending = controller.pendingTasks;
        final completed = controller.completedTasks;

        if (pending.isEmpty && completed.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhuma tarefa para hoje',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 88),
          children: [
            // Pendentes
            if (pending.isNotEmpty) ...[
              _sectionHeader(context, 'Pendentes', pending.length),
              ...pending.map((task) => _buildCard(context, task)),
            ],

            // Concluídas
            if (completed.isNotEmpty) ...[
              _sectionHeader(context, 'Concluídas', completed.length),
              ...completed.map((task) => _buildCard(context, task)),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '$title ($count)',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, TaskItem task) {
    final controller = context.read<TaskController>();
    final messenger = ScaffoldMessenger.of(context);
    final subtasks = controller.subtasksForTask(task.id);
    return TaskCard(
      task: task,
      subtasks: subtasks.isEmpty ? null : subtasks,
      onToggleSubtask: (subtaskId) =>
          _onToggleSubtask(context, task, subtaskId),
      onTap: () => _onCardTap(context, task),
      onToggleComplete: () => _onToggleComplete(context, task),
      onDelete: () => _onDelete(controller, messenger, task),
    );
  }

  Future<void> _onToggleSubtask(
      BuildContext context, TaskItem task, int subtaskId) async {
    final controller = context.read<TaskController>();
    try {
      await controller.taskRepo.toggleSubtask(subtaskId);
      if (!context.mounted) return;
      // Recarrega o cache para garantir consistência com o banco
      unawaited(controller.refreshSubtaskCacheForTask(task.id));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alternar subtarefa: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _onDelete(
    TaskController controller,
    ScaffoldMessengerState messenger,
    TaskItem task,
  ) async {
    try {
      await controller.deleteTask(task.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao remover: $e'),
        ),
      );
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('"${task.title}" removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () async {
              try {
                await controller.undoDelete();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro ao desfazer: $e'),
                  ),
                );
              }
            },
          ),
        ),
      );
  }
}

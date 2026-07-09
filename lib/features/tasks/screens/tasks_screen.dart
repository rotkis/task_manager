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
        durationMinutes: task.durationMinutes ??
            (task.type == TaskType.pomodoroStudy
                ? AppConstants.defaultPomodoroFocusMinutes
                : AppConstants.defaultTimedExerciseMinutes),
        breakDurationMinutes: task.type == TaskType.pomodoroStudy
            ? AppConstants.defaultPomodoroBreakMinutes
            : 0,
        onFinish: () {
          Navigator.of(ctx).pop();
          context.read<TaskController>().completeTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa concluída!')),
          );
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
        onComplete: () {
          Navigator.of(ctx).pop();
          context.read<TaskController>().completeTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${task.title} concluída!')),
          );
        },
      ),
    );
  }

  void _onDelete(BuildContext context, TaskItem task) {
    final controller = context.read<TaskController>();
    controller.deleteTask(task.id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('"${task.title}" removida'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => controller.undoDelete(),
          ),
        ),
      );
  }

  void _onToggleComplete(BuildContext context, TaskItem task) {
    if (task.isCompleted) return;
    context.read<TaskController>().completeTask(task.id);
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
    return TaskCard(
      task: task,
      onTap: () => _onCardTap(context, task),
      onToggleComplete: () => _onToggleComplete(context, task),
      onDelete: () => _onDelete(context, task),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/models/task_item.dart';
import '../../tasks/controllers/task_controller.dart';
import '../../tasks/screens/tasks_screen.dart';
import '../../tasks/widgets/task_card.dart';

/// Lista de tarefas de um dia específico, ordenada por horário.
///
/// Cada card suporta:
/// - Tap → abre o [TaskForm] em modo edição (reaproveita Módulo 1).
/// - Swipe → deleta com undo.
/// - Checkbox/toggle → conclui a tarefa.
/// - Subtarefas: exibe progresso e checkboxes interativos com toggle.
class ScheduleList extends StatelessWidget {
  /// Tarefas a exibir (já filtradas e ordenadas para o dia).
  final List<TaskItem> tasks;

  /// Dia a que estas tarefas pertencem (exibido no cabeçalho).
  final DateTime day;

  /// Se verdadeiro, exibe "Nenhuma tarefa" quando a lista é vazia.
  final bool showEmptyHeader;

  const ScheduleList({
    super.key,
    required this.tasks,
    required this.day,
    this.showEmptyHeader = true,
  });

  void _openEdit(BuildContext context, TaskItem task) {
    TasksScreen.openForm(context, task: task);
  }

  Future<void> _onDelete(BuildContext context, TaskItem task) async {
    final controller = context.read<TaskController>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.deleteTask(task.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao remover: $e')),
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
                  SnackBar(content: Text('Erro ao desfazer: $e')),
                );
              }
            },
          ),
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

  Future<void> _onToggleSubtask(
      BuildContext context, TaskItem task, int subtaskId) async {
    final controller = context.read<TaskController>();
    try {
      await controller.taskRepo.toggleSubtask(subtaskId);
      if (!context.mounted) return;
      await controller.refreshSubtaskCacheForTask(task.id);
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

  @override
  Widget build(BuildContext context) {
    // Observa mudanças no TaskController para subtarefas e conclusões
    final taskController = context.watch<TaskController>();

    if (tasks.isEmpty) {
      if (showEmptyHeader) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Nenhuma tarefa para ${DateFormat('dd/MM').format(day)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        // Cabeçalho do dia
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            DateFormat('EEEE, dd \'de\' MMMM', 'pt_BR').format(day),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ),
        ...tasks.map((task) {
          final subtasks = taskController.subtasksForTask(task.id);
          return TaskCard(
            task: task,
            subtasks: subtasks.isEmpty ? null : subtasks,
            onToggleSubtask: (subtaskId) =>
                _onToggleSubtask(context, task, subtaskId),
            onTap: () => _openEdit(context, task),
            onToggleComplete: () => _onToggleComplete(context, task),
            onDelete: () => _onDelete(context, task),
          );
        }),
      ],
    );
  }
}

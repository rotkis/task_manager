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

/// Filtro de status de tarefa para a tela principal.
enum TaskStatusFilter { all, pending, completed, overdue }

/// Tela principal de tarefas.
///
/// Exibe as tarefas do dia corrente divididas em duas seções:
/// pendentes (não concluídas) e concluídas. Um FAB abre o
/// formulário de nova tarefa ([TaskForm]).
///
/// Suporta busca textual por título/descrição e filtros por tipo,
/// status e data (Módulo 11).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  /// Abre o formulário de criação/edição de tarefa.
  static void openForm(BuildContext context, {TaskItem? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskForm(task: task),
      ),
    );
  }

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  TaskType? _typeFilter;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  /// `true` quando há pelo menos um filtro de tipo ou status ativo
  /// (a busca textual fica sempre visível, não entra neste cálculo).
  bool get _hasActiveFilters =>
      _typeFilter != null || _statusFilter != TaskStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEdit(BuildContext context, TaskItem task) {
    TasksScreen.openForm(context, task: task);
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

  // ─── Filtros ──────────────────────────────────────────────────────────

  /// Filtra por status "Atrasadas": usa [TaskItem.isOverdue] diretamente,
  /// item a item — NÃO usa critério de data por dia. Isso garante que
  /// tarefas de hoje com horário já passado também sejam consideradas
  /// atrasadas, consistente com o indicador visual do [TaskCard].
  bool _isOverdue(TaskItem task) => task.isOverdue;

  /// Aplica os filtros atuais a uma lista de tarefas.
  List<TaskItem> _applyFilters(List<TaskItem> tasks) {
    return tasks.where((t) {
      // Filtro textual
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            (t.description == null ||
                !t.description!.toLowerCase().contains(q))) {
          return false;
        }
      }

      // Filtro por tipo
      if (_typeFilter != null && t.type != _typeFilter) return false;

      // Filtro por status
      switch (_statusFilter) {
        case TaskStatusFilter.all:
          break;
        case TaskStatusFilter.pending:
          if (t.isCompleted) return false;
        case TaskStatusFilter.completed:
          if (!t.isCompleted) return false;
        case TaskStatusFilter.overdue:
          if (!_isOverdue(t)) return false;
      }

      return true;
    }).toList();
  }

  // ─── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, _) {
        final pending = _applyFilters(controller.pendingTasks);
        final completed = _applyFilters(controller.completedTasks);

        return Column(
          children: [
            // Barra de busca com botão de filtro
            _buildSearchBar(context),
            // Lista de tarefas
            Expanded(
              child: pending.isEmpty && completed.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 88),
                      children: [
                        if (pending.isNotEmpty) ...[
                          _sectionHeader(context, 'Pendentes', pending.length),
                          ...pending.map(
                              (task) => _buildCard(context, controller, task)),
                        ],
                        if (completed.isNotEmpty) ...[
                          _sectionHeader(
                              context, 'Concluídas', completed.length),
                          ...completed.map(
                              (task) => _buildCard(context, controller, task)),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por título ou descrição…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              _buildFilterButton(context),
            ],
          ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (v) => setState(() => _searchQuery = v.trim()),
      ),
    );
  }

  /// Botão de filtro com indicador de estado ativo.
  Widget _buildFilterButton(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _openFilterSheet(context),
          tooltip: 'Filtrar',
        ),
        if (_hasActiveFilters)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  /// Abre o bottom sheet com os filtros de tipo e status.
  /// As alterações nos chips são aplicadas imediatamente ao estado
  /// do widget ([setState]). Fechar o painel NÃO reseta os filtros
  /// — apenas esconde a UI deles.
  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ────────────────────────────────────
              Row(
                children: [
                  Text('Filtrar tarefas',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(),
              // ── Tipo ──────────────────────────────────────
              Text('Tipo', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _sheetFilterChip(
                    label: 'Todos',
                    selected: _typeFilter == null,
                    onSelected: (_) {
                      setState(() => _typeFilter = null);
                      setSheetState(() {});
                    },
                  ),
                  for (final type in TaskType.values)
                    _sheetFilterChip(
                      label: _typeLabel(type),
                      selected: _typeFilter == type,
                      onSelected: (_) {
                        setState(() =>
                            _typeFilter = _typeFilter == type ? null : type);
                        setSheetState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Status ────────────────────────────────────
              Text('Status', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _sheetFilterChip(
                    label: 'Todas',
                    selected: _statusFilter == TaskStatusFilter.all,
                    onSelected: (_) {
                      setState(() => _statusFilter = TaskStatusFilter.all);
                      setSheetState(() {});
                    },
                  ),
                  _sheetFilterChip(
                    label: 'Pendentes',
                    selected: _statusFilter == TaskStatusFilter.pending,
                    onSelected: (_) {
                      setState(() => _statusFilter = TaskStatusFilter.pending);
                      setSheetState(() {});
                    },
                  ),
                  _sheetFilterChip(
                    label: 'Concluídas',
                    selected: _statusFilter == TaskStatusFilter.completed,
                    onSelected: (_) {
                      setState(
                          () => _statusFilter = TaskStatusFilter.completed);
                      setSheetState(() {});
                    },
                  ),
                  _sheetFilterChip(
                    label: 'Atrasadas',
                    selected: _statusFilter == TaskStatusFilter.overdue,
                    onSelected: (_) {
                      setState(() => _statusFilter = TaskStatusFilter.overdue);
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Ações ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _typeFilter = null;
                        _statusFilter = TaskStatusFilter.all;
                      });
                      setSheetState(() {});
                    },
                    child: const Text('Limpar'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chip de filtro usado dentro do bottom sheet.
  Widget _sheetFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool?> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
    );
  }

  String _typeLabel(TaskType type) {
    switch (type) {
      case TaskType.generic:
        return 'Genérica';
      case TaskType.pomodoroStudy:
        return 'Pomodoro';
      case TaskType.timedExercise:
        return 'Timer';
      case TaskType.repsExercise:
        return 'Repetições';
    }
  }

  Widget _buildEmptyState() {
    // Se há filtros ativos mas nenhum resultado, mostra mensagem
    // diferente da "sem tarefas" padrão.
    if (_searchQuery.isNotEmpty ||
        _typeFilter != null ||
        _statusFilter != TaskStatusFilter.all) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma tarefa corresponde aos filtros',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _typeFilter = null;
                  _statusFilter = TaskStatusFilter.all;
                });
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      );
    }

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

  Widget _buildCard(
      BuildContext context, TaskController controller, TaskItem task) {
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

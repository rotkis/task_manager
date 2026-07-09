import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/task_item.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../core/utils/date_helpers.dart';

/// Gerencia o estado das tarefas do dia corrente.
/// Expõe listas reativas de pendentes e concluídas e oferece
/// métodos de CRUD que delegam ao [TaskRepository].
///
/// Também chama [ProgressRepository] ao concluir uma tarefa para
/// alimentar o gráfico de evolução e a streak.
class TaskController extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final ProgressRepository _progressRepo;

  StreamSubscription<List<TaskItem>>? _tasksSub;

  List<TaskItem> _todayTasks = [];
  TaskItem? _lastDeletedTask;

  TaskController({
    TaskRepository? taskRepo,
    ProgressRepository? progressRepo,
  })  : _taskRepo = taskRepo ?? TaskRepository(),
        _progressRepo = progressRepo ?? ProgressRepository();

  // ─── Listas reativas ───────────────────────────────────────────────

  List<TaskItem> get todayTasks => _todayTasks;

  List<TaskItem> get pendingTasks =>
      _todayTasks.where((t) => !t.isCompleted).toList();

  List<TaskItem> get completedTasks =>
      _todayTasks.where((t) => t.isCompleted).toList();

  /// Tarefa deletada aguardando possível undo.
  TaskItem? get lastDeletedTask => _lastDeletedTask;

  // ─── Inicialização ─────────────────────────────────────────────────

  /// Inicia a escuta do stream de tarefas do dia corrente.
  /// Deve ser chamado após a construção (ex: `controller..init()`).
  void init() {
    _tasksSub?.cancel();
    _tasksSub = _taskRepo.watchByDate(DateHelpers.today()).listen((tasks) {
      _todayTasks = tasks;
      notifyListeners();
    });
  }

  // ─── CRUD ──────────────────────────────────────────────────────────

  /// Cria uma nova tarefa e persiste no banco.
  Future<void> createTask(TaskItem task) async {
    await _taskRepo.create(task);
  }

  /// Atualiza uma tarefa existente.
  Future<void> updateTask(TaskItem task) async {
    await _taskRepo.update(task);
  }

  /// Remove uma tarefa pelo [id]. Guarda a tarefa removida para
  /// possível undo via [undoDelete].
  Future<void> deleteTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task != null) {
      _lastDeletedTask = task;
      await _taskRepo.delete(id);
    }
  }

  /// Restaura a última tarefa deletada.
  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      final restored = _lastDeletedTask!;
      _lastDeletedTask = null;
      await _taskRepo.create(restored);
    }
  }

  /// Marca a tarefa como concluída, registra timestamp e soma
  /// pontos no [ProgressRepository] do dia corrente.
  Future<void> completeTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task == null || task.isCompleted) return;

    task.isCompleted = true;
    task.completedAt = DateTime.now();
    await _taskRepo.update(task);
    await _progressRepo.incrementToday(task.rewardPoints);
  }

  // ─── Limpeza ───────────────────────────────────────────────────────

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}

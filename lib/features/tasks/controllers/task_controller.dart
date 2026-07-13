import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/task_item.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../core/utils/date_helpers.dart';
import '../../notifications/alarm_service.dart';
import '../../notifications/notification_service.dart';

/// Gerencia o estado das tarefas do dia corrente.
/// Expõe listas reativas de pendentes e concluídas e oferece
/// métodos de CRUD que delegam ao [TaskRepository].
///
/// Também chama [ProgressRepository] ao concluir uma tarefa para
/// alimentar o gráfico de evolução e a streak.
///
/// Gerencia o agendamento/cancelamento de notificações e alarmes através
/// de [NotificationService] e [AlarmService] — nunca direto da UI (ver
/// plan.md seção 2.1).
class TaskController extends ChangeNotifier {
  final TaskRepository _taskRepo;
  final ProgressRepository _progressRepo;
  final NotificationService _notificationService;
  final AlarmService _alarmService;

  /// Expõe o repositório de tarefas para controllers de outras features
  /// (ex: [CalendarController]) sem violar a arquitetura de camadas.
  TaskRepository get taskRepo => _taskRepo;

  StreamSubscription<List<TaskItem>>? _tasksSub;
  StreamSubscription<List<TaskItem>>? _allTasksSub;

  List<TaskItem> _todayTasks = [];
  List<TaskItem> _allTasks = [];
  TaskItem? _lastDeletedTask;
  bool _disposed = false;

  TaskController({
    TaskRepository? taskRepo,
    ProgressRepository? progressRepo,
    NotificationService? notificationService,
    AlarmService? alarmService,
  })  : _taskRepo = taskRepo ?? TaskRepository(),
        _progressRepo = progressRepo ?? ProgressRepository(),
        _notificationService = notificationService ?? NotificationService(),
        _alarmService = alarmService ?? AlarmService();

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
      if (_disposed) return;
      _todayTasks = tasks;
      notifyListeners();
    });

    _allTasksSub?.cancel();
    _allTasksSub = _taskRepo.watchAll().listen((tasks) {
      if (_disposed) return;
      _allTasks = tasks;
      notifyListeners();
    });

    // Garante instâncias futuras de tarefas recorrentes (fire-and-forget)
    _taskRepo.ensureUpcomingInstances().catchError((e) {
      debugPrint('ensureUpcomingInstances error: $e');
    });
  }

  /// Lista completa de todas as tarefas (usada pela tela de compartilhar).
  List<TaskItem> get allTasks => _allTasks;

  /// [TEST-ONLY] Injeta tarefas diretamente sem depender do stream do Isar.
  /// Usado exclusivamente por golden/regression tests que não podem manter
  /// um stream vivo no ambiente testWidgets.
  @visibleForTesting
  void setTodayTasksDirectly(List<TaskItem> tasks) {
    _todayTasks = tasks;
    notifyListeners();
  }

  // ─── CRUD ──────────────────────────────────────────────────────────

  /// Cria uma nova tarefa, persiste no banco e agenda notificação/alarme.
  Future<void> createTask(TaskItem task) async {
    await _taskRepo.create(task);
    await _scheduleForTask(task);
  }

  /// Atualiza uma tarefa existente.
  ///
  /// Cancela a notificação/alarme antigo antes de atualizar e agenda o
  /// novo com os dados atualizados.
  Future<void> updateTask(TaskItem task) async {
    final oldTask = await _taskRepo.getById(task.id);
    if (oldTask != null) {
      await _cancelNotificationAndAlarm(oldTask);
    }
    await _taskRepo.update(task);
    await _scheduleForTask(task);
  }

  /// Remove uma tarefa pelo [id]. Cancela notificação/alarme antes de
  /// deletar. Guarda a tarefa removida para possível undo via
  /// [undoDelete].
  Future<void> deleteTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task != null) {
      await _cancelNotificationAndAlarm(task);
      _lastDeletedTask = task;
      await _taskRepo.delete(id);
    }
  }

  /// Restaura a última tarefa deletada e re-agenda notificação/alarme.
  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      final restored = _lastDeletedTask!;
      _lastDeletedTask = null;
      // Limpa os IDs antigos pois a tarefa terá um novo id no banco
      restored.notificationId = null;
      restored.alarmId = null;
      await _taskRepo.create(restored);
      await _scheduleForTask(restored);
    }
  }

  /// Marca a tarefa como concluída, registra timestamp, soma pontos no
  /// [ProgressRepository] e cancela notificação/alarme pendente.
  Future<void> completeTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task == null || task.isCompleted) return;

    task.isCompleted = true;
    task.completedAt = DateTime.now();
    await _taskRepo.update(task);
    await _progressRepo.incrementToday(task.rewardPoints);
    await _cancelNotificationAndAlarm(task);
  }

  // ─── Agendamento de notificação/alarme ────────────────────────────

  /// Agenda notificação ou alarme para [task] conforme o valor de
  /// [TaskItem.isNotificationEnabled] e [TaskItem.isImportant].
  ///
  /// Se [isNotificationEnabled] for `false`, cancela qualquer notificação
  /// ou alarme previamente agendado para esta tarefa.
  Future<void> _scheduleForTask(TaskItem task) async {
    // Se a notificação está desligada ou não há data/horário, cancela
    // o que já existir e retorna
    if (!task.isNotificationEnabled ||
        task.scheduledDate == null ||
        task.scheduledTime == null) {
      await _cancelNotificationAndAlarm(task);
      return;
    }

    if (task.isImportant) {
      await _alarmService.schedule(task);
    } else {
      await _notificationService.schedule(task);
    }

    // Persiste o id da notificação/alarme que foi definido pelo service
    await _taskRepo.update(task);
  }

  /// Cancela notificação e alarme associados a [task], se existirem.
  Future<void> _cancelNotificationAndAlarm(TaskItem task) async {
    if (task.notificationId != null) {
      await _notificationService.cancel(task.notificationId!);
    }
    if (task.alarmId != null) {
      await _alarmService.cancel(task.alarmId!);
    }
  }

  // ─── Limpeza ───────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    _tasksSub?.cancel();
    _allTasksSub?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../../../data/models/task_item.dart';
import '../../../data/models/sub_task_item.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../core/utils/date_helpers.dart';
import '../../notifications/alarm_service.dart';
import '../../notifications/notification_service.dart';
import '../../widget/widget_data_service.dart';
import '../../calendar/services/calendar_renderer_service.dart';

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
  final WidgetDataService _widgetDataService;

  /// Expõe o repositório de tarefas para controllers de outras features
  /// (ex: [CalendarController]) sem violar a arquitetura de camadas.
  TaskRepository get taskRepo => _taskRepo;

  StreamSubscription<List<TaskItem>>? _tasksSub;
  StreamSubscription<List<TaskItem>>? _allTasksSub;

  List<TaskItem> _todayTasks = [];
  List<TaskItem> _allTasks = [];
  TaskItem? _lastDeletedTask;
  bool _disposed = false;

  /// Cache de subtarefas por id da tarefa-pai.
  /// Preenchido sempre que [_todayTasks] ou [_allTasks] é atualizado
  /// (para tarefas de dias futuros no calendário).
  final Map<int, List<SubTaskItem>> _subtaskCache = {};

  /// Subtarefas para uma tarefa específica.
  ///
  /// Se a tarefa ainda não está no cache (ex: dia futuro no calendário),
  /// dispara uma busca assíncrona e retorna lista vazia temporariamente.
  /// Quando a busca completar, o cache é atualizado e a UI reconstroi.
  /// Em ambiente de teste ([FLUTTER_TEST]), não dispara a busca para
  /// evitar conflito com FakeAsync (Isar FFI nunca completa).
  List<SubTaskItem> subtasksForTask(int taskId) {
    if (_subtaskCache.containsKey(taskId)) return _subtaskCache[taskId]!;
    if (!_inTest) _lazyLoadSubtasks(taskId);
    return [];
  }

  /// Busca subtarefas para [taskId] que não estava em cache e atualiza
  /// o cache quando a consulta retorna.
  void _lazyLoadSubtasks(int taskId) {
    _taskRepo.getSubtasks(taskId).then((list) {
      if (_disposed) return;
      _subtaskCache[taskId] = list;
      notifyListeners();
    });
  }

  static bool get _inTest =>
      Platform.environment.containsKey('FLUTTER_TEST') ||
      Platform.environment.containsKey('APP_TEST');

  TaskController({
    TaskRepository? taskRepo,
    ProgressRepository? progressRepo,
    NotificationService? notificationService,
    AlarmService? alarmService,
    WidgetDataService? widgetDataService,
  })  : _taskRepo = taskRepo ?? TaskRepository(),
        _progressRepo = progressRepo ?? ProgressRepository(),
        _notificationService = notificationService ?? NotificationService(),
        _alarmService = alarmService ?? AlarmService(),
        _widgetDataService = widgetDataService ?? WidgetDataService();

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
      // A UI só será notificada depois que o cache de subtarefas
      // estiver carregado (dentro de [_refreshSubtaskCache]).
      _refreshSubtaskCache();
      // Sincroniza o widget com os dados mais recentes (Módulo 12).
      _updateWidget();
    });

    _allTasksSub?.cancel();
    _allTasksSub = _taskRepo.watchAll().listen((tasks) {
      if (_disposed) return;
      _allTasks = tasks;
      notifyListeners();
      // Garante que o widget de calendário seja atualizado com a
      // lista completa de tarefas (pode ter emitido depois de
      // [_tasksSub], que é o único que chama [_updateWidget]).
      _updateWidget();
    });

    // Garante instâncias futuras de tarefas recorrentes (fire-and-forget)
    _taskRepo.ensureUpcomingInstances().catchError((e) {
      debugPrint('ensureUpcomingInstances error: $e');
    });
  }

  /// Atualiza o cache de subtarefas para as tarefas do dia.
  /// Só chama [notifyListeners] depois que o cache está pronto, para
  /// evitar renderizar a lista com "Passos: 0/0" antes dos dados reais.
  void _refreshSubtaskCache() {
    _taskRepo
        .getSubtasksForTasks(_todayTasks.map((t) => t.id).toList())
        .then((cache) {
      if (_disposed) return;
      _subtaskCache
        ..clear()
        ..addAll(cache);
      notifyListeners();
    });
  }

  /// Força a atualização do cache de subtarefas para uma tarefa
  /// específica. Usado pelo [TaskForm] após persistir subtarefas
  /// pendentes na criação da tarefa.
  Future<void> refreshSubtaskCacheForTask(int taskId) async {
    final list = await _taskRepo.getSubtasks(taskId);
    if (_disposed) return;
    _subtaskCache[taskId] = list;
    notifyListeners();
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
  ///
  /// Se [subtasks] for fornecido, persiste as subtarefas ANTES de gerar
  /// instâncias recorrentes, para que [ensureUpcomingInstances] possa
  /// copiá-las para cada instância gerada.
  ///
  /// Se a tarefa for um modelo recorrente ([recurrenceRule] preenchido),
  /// já gera as instâncias futuras.
  Future<void> createTask(TaskItem task, {List<SubTaskItem>? subtasks}) async {
    await _taskRepo.create(task);
    await _scheduleForTask(task);

    // Persiste subtarefas antes de gerar instâncias recorrentes, para
    // que ensureUpcomingInstances copie as subtarefas do modelo para
    // cada instância.
    if (subtasks != null && subtasks.isNotEmpty) {
      for (final sub in subtasks) {
        sub.parentTaskId = task.id;
        await _taskRepo.addSubtask(sub);
      }
    }

    if (task.recurrenceRule != null && task.recurrenceRule!.isNotEmpty) {
      await _taskRepo.ensureUpcomingInstances();
    }
  }

  /// Atualiza uma tarefa existente.
  ///
  /// Cancela a notificação/alarme antigo antes de atualizar e agenda o
  /// novo com os dados atualizados. Se a tarefa for um modelo recorrente,
  /// regenera as instâncias futuras.
  ///
  /// Se a [scheduledDate] mudou para uma data **posterior** à anterior,
  /// incrementa [postponeCount] (nudge de adiamento repetido, Módulo 8).
  Future<void> updateTask(TaskItem task) async {
    final oldTask = await _taskRepo.getById(task.id);
    if (oldTask != null) {
      await _cancelNotificationAndAlarm(oldTask);
      // Verifica se a data foi empurrada pra frente
      if (oldTask.scheduledDate != null && task.scheduledDate != null) {
        final oldDate = DateHelpers.normalizeToDay(oldTask.scheduledDate!);
        final newDate = DateHelpers.normalizeToDay(task.scheduledDate!);
        if (newDate.isAfter(oldDate)) {
          task.postponeCount += 1;
        }
      }
    }
    await _taskRepo.update(task);
    await _scheduleForTask(task);
    if (task.recurrenceRule != null && task.recurrenceRule!.isNotEmpty) {
      await _taskRepo.ensureUpcomingInstances();
    }
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
  /// [ProgressRepository], zera [postponeCount] e cancela notificação/alarme
  /// pendente.
  Future<void> completeTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task == null || task.isCompleted) return;

    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.postponeCount = 0; // reset ao completar
    await _taskRepo.update(task);
    await _progressRepo.incrementToday(task.rewardPoints);
    await _cancelNotificationAndAlarm(task);
    await _updateWidget();
  }

  /// Reverte a conclusão de uma tarefa: marca como pendente, limpa o
  /// timestamp, subtrai os pontos do [ProgressRepository] do dia,
  /// zera [postponeCount] e re-agenda a notificação/alarme (se houver
  /// data/horário).
  Future<void> uncompleteTask(int id) async {
    final task = await _taskRepo.getById(id);
    if (task == null || !task.isCompleted) return;

    task.isCompleted = false;
    task.completedAt = null;
    task.postponeCount = 0; // reset ao desconcluir
    await _taskRepo.update(task);
    await _progressRepo.decrementToday(task.rewardPoints);
    // Re-agenda notificação/alarme já que a tarefa voltou a ficar pendente
    await _scheduleForTask(task);
    await _updateWidget();
  }

  /// Agenda notificação/alarme para uma lista de tarefas importadas.
  ///
  /// Usado após importação de backup (Módulo 9) ou compartilhamento
  /// (Módulo 5) para garantir que tarefas com data/horário agendados
  /// tenham notificação ativa sem o usuário precisar editá-las manualmente.
  Future<void> scheduleNotificationsForTasks(List<TaskItem> tasks) async {
    for (final task in tasks) {
      await _scheduleForTask(task);
    }
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

  // ─── Atualização dos widgets de tela inicial (Módulos 12 + calendário) ──

  /// Fire-and-forget: atualiza os dados dos widgets Android.
  ///
  /// ### Widget de tarefas de hoje
  /// Salva contagem de pendentes, streak e lista de até 5 tarefas
  /// pendentes ordenadas por horário no SharedPreferences e força
  /// a re-renderização do [TaskWidgetProvider].
  ///
  /// ### Widget de calendário
  /// Para cada widget de calendário instalado, lê o mês que ele está
  /// exibindo (por appWidgetId), renderiza o PNG correspondente e
  /// salva os dados de tarefas daquele mês.  Também salva dados dos
  /// meses adjacentes para que a navegação por setas no widget
  /// (via [CalendarWidgetNavReceiver]) tenha dados de tarefas
  /// disponíveis sem precisar abrir o app.
  Future<void> _updateWidget() async {
    try {
      // ── Widget de tarefas de hoje ──────────────────────────────
      final pending = pendingTasks.length;
      final log = await _progressRepo.getByDay(DateHelpers.today());
      final streak = log?.currentStreak ?? 0;

      await _widgetDataService.updateTaskWidget(
        pendingCount: pending,
        streak: streak,
        pendingTasks: pendingTasks,
      );

      // ── Widget de calendário mensal (PNG + dados de tarefas) ───
      final months = await _widgetDataService.getDisplayedCalendarMonths();

      // Também salva dados para meses adjacentes (±1) para que a
      // navegação do widget tenha dados de tarefas pré-carregados.
      final now = DateTime.now();
      final allMonths = <String>{...months};
      for (final ym in months.toList()) {
        final parts = ym.split('_');
        if (parts.length != 2) continue;
        final y = int.tryParse(parts[0]) ?? now.year;
        final m = int.tryParse(parts[1]) ?? now.month;
        // Mês anterior
        final prev = DateTime(y, m - 1);
        allMonths.add('${prev.year}_${prev.month}');
        // Próximo mês
        final next = DateTime(y, m + 1);
        allMonths.add('${next.year}_${next.month}');
      }

      for (final ym in allMonths) {
        final parts = ym.split('_');
        if (parts.length != 2) continue;
        final year = int.tryParse(parts[0]) ?? now.year;
        final month = int.tryParse(parts[1]) ?? now.month;

        // Filtra tarefas do mês
        final monthStart = DateHelpers.normalizeToDay(DateTime(year, month, 1));
        final monthEnd =
            DateHelpers.normalizeToDay(DateTime(year, month + 1, 0));
        final monthTasks = _allTasks.where((t) {
          if (t.scheduledDate == null) return false;
          final d = DateHelpers.normalizeToDay(t.scheduledDate!);
          return !d.isBefore(monthStart) && !d.isAfter(monthEnd);
        }).toList();

        // Renderiza o PNG do calendário com bolinhas de status
        await CalendarRendererService.renderAndSave(
          tasks: monthTasks,
          year: year,
          month: month,
        );
        // Mapa dia → (count, allDone) para renderizar bolinhas
        // no widget de calendário (verde se tudo concluído, roxo se
        // alguma pendente, até 3 bolinhas + "+N").
        final Map<int, ({int count, bool allDone})> daySummary = {};
        for (final task in monthTasks) {
          if (task.scheduledDate == null) continue;
          final day = task.scheduledDate!.day;
          final current = daySummary[day] ?? (count: 0, allDone: true);
          daySummary[day] = (
            count: current.count + 1,
            allDone: current.allDone && task.isCompleted,
          );
        }

        await _widgetDataService.saveCalendarTaskData(
          year: year,
          month: month,
          daySummary: daySummary,
        );
      }

      // Atualiza os widgets de calendário para refletirem os novos PNGs
      await _widgetDataService.refreshCalendarWidgets();
    } catch (_) {
      // Falha segura — não interrompe o fluxo principal do app.
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

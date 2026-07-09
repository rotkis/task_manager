import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/task_item.dart';
import '../../../data/repositories/task_repository.dart';

/// Gerencia o estado da tela de calendário/cronograma.
///
/// Expõe um mapa `DateTime -> List<TaskItem>` para os dias que têm
/// tarefas, a partir do [TaskRepository]. O [selectedDay] controla
/// qual dia está selecionado no [table_calendar].
class CalendarController extends ChangeNotifier {
  final TaskRepository _taskRepo;

  StreamSubscription<List<TaskItem>>? _tasksSub;

  /// Mapa: data normalizada (meia-noite) → lista de tarefas daquele dia.
  final Map<DateTime, List<TaskItem>> _tasksByDay = {};

  /// Dia atualmente selecionado no calendário.
  DateTime _selectedDay = DateTime.now();

  /// Mês atualmente focado no calendário.
  DateTime _focusedMonth = DateTime.now();

  CalendarController({
    TaskRepository? taskRepo,
  }) : _taskRepo = taskRepo ?? TaskRepository();

  // ─── Getters ────────────────────────────────────────────────────────

  /// Dia selecionado no calendário.
  DateTime get selectedDay => _selectedDay;

  /// Mês focado no calendário.
  DateTime get focusedMonth => _focusedMonth;

  /// Mapa de dias que têm pelo menos uma tarefa.
  Map<DateTime, List<TaskItem>> get tasksByDay => Map.unmodifiable(_tasksByDay);

  /// Retorna as tarefas do dia selecionado, ordenadas por horário.
  List<TaskItem> get selectedDayTasks {
    final normalized = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final tasks = _tasksByDay[normalized] ?? [];
    tasks.sort((a, b) {
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1;
      if (b.scheduledTime == null) return -1;
      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });
    return tasks;
  }

  /// Dias que têm tarefas (para os marcadores do calendário).
  Set<DateTime> get daysWithTasks => _tasksByDay.keys.toSet();

  // ─── Inicialização ──────────────────────────────────────────────────

  /// Inicia a escuta de todas as tarefas e constrói o mapa.
  void init() {
    _tasksSub?.cancel();
    _tasksSub = _taskRepo.watchAll().listen((tasks) {
      _buildDayMap(tasks);
      notifyListeners();
    });
  }

  /// Reconstrói o mapa [tasksByDay] a partir da lista plana de tarefas.
  void _buildDayMap(List<TaskItem> tasks) {
    _tasksByDay.clear();
    for (final task in tasks) {
      if (task.scheduledDate == null) continue;
      final day = DateTime(
        task.scheduledDate!.year,
        task.scheduledDate!.month,
        task.scheduledDate!.day,
      );
      _tasksByDay.putIfAbsent(day, () => []);
      // Evita duplicatas na mesma lista
      if (!_tasksByDay[day]!.any((t) => t.id == task.id)) {
        _tasksByDay[day]!.add(task);
      }
    }
  }

  // ─── Ações do calendário ────────────────────────────────────────────

  /// Define o dia selecionado e notifica ouvintes.
  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  /// Define o mês focado (quando o usuário navega no calendário).
  void focusMonth(DateTime month) {
    _focusedMonth = month;
    notifyListeners();
  }

  /// Formato usado pelo [table_calendar] para os formatos de evento.
  /// Retorna a lista de tarefas para [day].
  List<TaskItem> getTasksForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _tasksByDay[normalized] ?? [];
  }

  // ─── Limpeza ────────────────────────────────────────────────────────

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}

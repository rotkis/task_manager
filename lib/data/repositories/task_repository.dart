import 'dart:async';

import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/task_item.dart';
import '../../core/utils/date_helpers.dart';

/// Camada de acesso a dados para [TaskItem].
/// Apenas repositories e models importam isar_community diretamente.
class TaskRepository {
  Isar get _isar => IsarService.instance;

  // ─── CRUD ──────────────────────────────────────────────────────────

  Future<int> create(TaskItem task) async {
    return _isar.writeTxn(() => _isar.taskItems.put(task));
  }

  Future<int> update(TaskItem task) async {
    return _isar.writeTxn(() => _isar.taskItems.put(task));
  }

  Future<bool> delete(int id) async {
    return _isar.writeTxn(() => _isar.taskItems.delete(id));
  }

  /// Busca uma tarefa pelo id. Retorna null se não encontrada.
  Future<TaskItem?> getById(int id) async {
    return _isar.taskItems.get(id);
  }

  // ─── Streams (reativos) ────────────────────────────────────────────

  /// Stream de todas as tarefas (ordenadas por data de criação, mais
  /// novas primeiro).
  Stream<List<TaskItem>> watchAll() {
    return _isar.taskItems
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Stream de tarefas pendentes (isCompleted = false), ordenadas por
  /// data agendada e depois horário.
  Stream<List<TaskItem>> watchPending() {
    return _isar.taskItems
        .where()
        .filter()
        .isCompletedEqualTo(false)
        .sortByScheduledDate()
        .thenByScheduledTime()
        .watch(fireImmediately: true);
  }

  /// Stream de tarefas de um dia específico (normalizado à meia-noite).
  Stream<List<TaskItem>> watchByDate(DateTime date) {
    final normalized = DateHelpers.normalizeToDay(date);
    return _isar.taskItems
        .where()
        .filter()
        .scheduledDateEqualTo(normalized)
        .sortByScheduledTime()
        .watch(fireImmediately: true);
  }

  /// Stream de tarefas de um intervalo de dias.
  Stream<List<TaskItem>> watchByDateRange(DateTime start, DateTime end) {
    final s = DateHelpers.normalizeToDay(start);
    final e = DateHelpers.normalizeToDay(end);
    return _isar.taskItems
        .where()
        .filter()
        .scheduledDateBetween(s, e)
        .sortByScheduledDate()
        .thenByScheduledTime()
        .watch(fireImmediately: true);
  }
}

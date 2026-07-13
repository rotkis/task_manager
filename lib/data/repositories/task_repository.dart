import 'dart:async';

import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/task_item.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/utils/recurrence_parser.dart';

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

  // ─── Recorrência (Módulo 6) ─────────────────────────────────────────

  /// Busca todas as tarefas-modelo (aquelas com [recurrenceRule] preenchido
  /// e que NÃO são instâncias — ou seja, [parentRecurringId] é nulo).
  Future<List<TaskItem>> getModelTasks() {
    return _isar.taskItems
        .where()
        .filter()
        .recurrenceRuleIsNotNull()
        .parentRecurringIdIsNull()
        .findAll();
  }

  /// Busca instâncias (tarefas com [parentRecurringId] igual a [modelId])
  /// cuja data agendada esteja entre [start] e [end] (inclusive).
  Future<List<TaskItem>> getInstancesInRange(
    int modelId,
    DateTime start,
    DateTime end,
  ) {
    final s = DateHelpers.normalizeToDay(start);
    final e = DateHelpers.normalizeToDay(end);
    return _isar.taskItems
        .where()
        .filter()
        .parentRecurringIdEqualTo(modelId)
        .scheduledDateBetween(s, e)
        .findAll();
  }

  /// Garante que existam instâncias concretas da tarefa-modelo [model]
  /// para os próximos [daysAhead] dias (a partir de hoje).
  ///
  /// Cria apenas as que **não** existirem ainda, evitando duplicatas.
  /// As instâncias copiam título, descrição, tipo, duração, pontos etc.
  /// da tarefa-modelo, mas têm [parentRecurringId] apontando para ela e
  /// [recurrenceRule] = null (cada instância é independente).
  Future<void> ensureInstancesForModel(TaskItem model,
      {int daysAhead = 30}) async {
    final rule = parseRecurrenceRule(model.recurrenceRule);
    if (rule.type == RecurrenceType.none) return;

    final today = DateHelpers.today();
    final endDate = today.add(Duration(days: daysAhead));

    // Gera todas as datas em que a tarefa deve ocorrer
    final dates = rule.generateDates(
      referenceDate: model.scheduledDate ?? model.createdAt,
      start: today,
      end: endDate,
    );

    if (dates.isEmpty) return;

    // Busca instâncias já existentes no período
    final existing = await getInstancesInRange(model.id, today, endDate);
    final existingDates = existing
        .map((e) =>
            DateHelpers.normalizeToDay(e.scheduledDate ?? DateTime(1970)))
        .toSet();

    // Cria as que faltam
    for (final date in dates) {
      if (!existingDates.contains(date)) {
        final instance = TaskItem()
          ..title = model.title
          ..description = model.description
          ..type = model.type
          ..rewardPoints = model.rewardPoints
          ..durationMinutes = model.durationMinutes
          ..durationSeconds = model.durationSeconds
          ..targetReps = model.targetReps
          ..targetSets = model.targetSets
          ..isNotificationEnabled = model.isNotificationEnabled
          ..isImportant = model.isImportant
          ..scheduledDate = date
          ..scheduledTime = model.scheduledTime
          ..parentRecurringId = model.id
          ..recurrenceRule = null; // instância não é modelo
        await _isar.writeTxn(() => _isar.taskItems.put(instance));
      }
    }
  }

  /// Varre todas as tarefas-modelo e chama [ensureInstancesForModel] para
  /// cada uma. Geralmente chamado uma vez ao abrir o app.
  Future<void> ensureUpcomingInstances({int daysAhead = 30}) async {
    final models = await getModelTasks();
    for (final model in models) {
      await ensureInstancesForModel(model, daysAhead: daysAhead);
    }
  }
}

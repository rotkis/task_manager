import 'dart:async';

import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/task_item.dart';
import '../models/sub_task_item.dart';
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

    // Ignora a data do próprio modelo — o modelo já é a tarefa desse dia
    final modelDate =
        DateHelpers.normalizeToDay(model.scheduledDate ?? model.createdAt);

    // Busca instâncias já existentes no período
    final existing = await getInstancesInRange(model.id, today, endDate);
    final existingDates = existing
        .map((e) =>
            DateHelpers.normalizeToDay(e.scheduledDate ?? DateTime(1970)))
        .toSet();

    // Cria as que faltam
    for (final date in dates) {
      if (date == modelDate) continue; // modelo já cobre este dia
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
        await _isar.writeTxn(() async {
          await _isar.taskItems.put(instance);
          // Copia as subtarefas do modelo para a nova instância
          final modelSubtasks = await _isar.subTaskItems
              .where()
              .filter()
              .parentTaskIdEqualTo(model.id)
              .sortByOrder()
              .findAll();
          for (final sub in modelSubtasks) {
            final clone = SubTaskItem()
              ..parentTaskId = instance.id
              ..title = sub.title
              ..type = sub.type
              ..isCompleted = false // instância nova começa não concluída
              ..order = sub.order;
            await _isar.subTaskItems.put(clone);
          }
        });
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

  // ─── Subtarefas (Módulo 7) ──────────────────────────────────────────

  /// Stream de subtarefas de uma tarefa, ordenadas por [order].
  Stream<List<SubTaskItem>> watchSubtasks(int parentTaskId) {
    return _isar.subTaskItems
        .where()
        .filter()
        .parentTaskIdEqualTo(parentTaskId)
        .sortByOrder()
        .watch(fireImmediately: true);
  }

  /// Busca todas as subtarefas de uma tarefa (one-shot).
  Future<List<SubTaskItem>> getSubtasks(int parentTaskId) {
    return _isar.subTaskItems
        .where()
        .filter()
        .parentTaskIdEqualTo(parentTaskId)
        .sortByOrder()
        .findAll();
  }

  /// Busca subtarefas para múltiplas tarefas de uma vez.
  /// Retorna um mapa de taskId → lista de subtarefas.
  Future<Map<int, List<SubTaskItem>>> getSubtasksForTasks(
      List<int> parentIds) async {
    if (parentIds.isEmpty) return {};
    final all = await _isar.subTaskItems.where().sortByOrder().findAll();
    final result = <int, List<SubTaskItem>>{};
    for (final id in parentIds) {
      result[id] = all.where((s) => s.parentTaskId == id).toList();
    }
    return result;
  }

  /// Adiciona uma subtarefa a uma tarefa.
  /// [order] é opcional; se não informado, calcula o próximo disponível.
  Future<int> addSubtask(SubTaskItem subtask) async {
    if (subtask.order == 0) {
      // Se não definida, coloca no final da lista
      final existing = await getSubtasks(subtask.parentTaskId);
      subtask.order = existing.isEmpty ? 0 : existing.last.order + 1;
    }
    return _isar.writeTxn(() => _isar.subTaskItems.put(subtask));
  }

  /// Alterna o estado [isCompleted] de uma subtarefa.
  Future<void> toggleSubtask(int subtaskId) async {
    final subtask = await _isar.subTaskItems.get(subtaskId);
    if (subtask == null) return;
    subtask.isCompleted = !subtask.isCompleted;
    await _isar.writeTxn(() => _isar.subTaskItems.put(subtask));
  }

  /// Remove uma subtarefa pelo [id].
  Future<bool> deleteSubtask(int id) async {
    return _isar.writeTxn(() => _isar.subTaskItems.delete(id));
  }

  /// Reordena as subtarefas de uma tarefa. Recebe uma lista de [ids] na
  /// nova ordem desejada. Atualiza o campo [order] de cada uma.
  Future<void> reorderSubtasks(int parentTaskId, List<int> ids) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < ids.length; i++) {
        final subtask = await _isar.subTaskItems.get(ids[i]);
        if (subtask != null && subtask.parentTaskId == parentTaskId) {
          subtask.order = i;
          await _isar.subTaskItems.put(subtask);
        }
      }
    });
  }
}

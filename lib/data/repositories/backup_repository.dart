import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/task_item.dart';
import '../models/sub_task_item.dart';
import '../models/progress_log.dart';
import '../../core/utils/backup_codec.dart';

/// Camada de acesso a dados para backup/restauração (Módulo 9).
///
/// Usa [backup_codec] para serializar/desserializar e gerencia a
/// persistência no Isar, incluindo o remapeamento de IDs das tarefas
/// para que as subtarefas mantenham a referência correta ao pai.
///
/// Apenas repositories e models importam isar_community diretamente.
class BackupRepository {
  Isar get _isar => IsarService.instance;

  /// Exporta **todas** as tarefas, subtarefas e logs de progresso
  /// para uma string JSON formatada (pronta para salvar em arquivo).
  Future<String> exportAll() async {
    final tasks = await _isar.taskItems.where().findAll();
    final subtasks = await _isar.subTaskItems.where().findAll();
    final logs = await _isar.progressLogs.where().findAll();

    return encodeBackup(
      tasks: tasks,
      subtasks: subtasks,
      progressLogs: logs,
    );
  }

  /// Importa dados de um backup.
  ///
  /// Se [merge] for `false`: apaga todos os dados existentes e substitui
  /// pelos do backup (cuidado: operação destrutiva).
  ///
  /// Se [merge] for `true`: adiciona os dados do backup aos existentes.
  /// Para progress logs, soma os valores do dia correspondente (merge
  /// cumulativo).
  ///
  /// Retorna a lista de [TaskItem] importados (com os IDs finais já
  /// atribuídos pelo Isar), para que o chamador possa agendar
  /// notificações/alarmes.
  ///
  /// Lança [FormatException] se o JSON for inválido ou tiver versão
  /// incompatível.
  Future<List<TaskItem>> importAll(String json, {required bool merge}) async {
    final data = decodeBackup(json);
    if (data == null) {
      throw FormatException('Arquivo de backup inválido ou corrompido.');
    }

    await _isar.writeTxn(() async {
      if (!merge) {
        await _isar.taskItems.clear();
        await _isar.subTaskItems.clear();
        await _isar.progressLogs.clear();
      }

      // ─── Tarefas ─────────────────────────────────────────
      // Mapa: oldId → newId (para remapear parentTaskId das subtarefas)
      final idMap = <int, int>{};

      for (final task in data.tasks) {
        final oldId = task.id;
        task.id = Isar.autoIncrement; // gera novo id
        // Runtime fields que não fazem sentido no novo dispositivo
        task.notificationId = null;
        task.alarmId = null;
        // Se for merge, não sobrepor completedAt (mantém o original do backup)
        // Se for replace, mantém o histórico
        final newId = await _isar.taskItems.put(task);
        idMap[oldId] = newId;
      }

      // ─── Subtarefas ───────────────────────────────────────
      for (final sub in data.subtasks) {
        sub.id = Isar.autoIncrement;
        // Remapeia parentTaskId para o novo id da tarefa correspondente
        final newParentId = idMap[sub.parentTaskId];
        if (newParentId != null) {
          sub.parentTaskId = newParentId;
        }
        // Se não encontrou o parent no mapa, mantém o original
        // (pode ser tarefa que já existia antes do merge)
        await _isar.subTaskItems.put(sub);
      }

      // ─── Logs de progresso ───────────────────────────────
      for (final log in data.progressLogs) {
        if (merge) {
          // Upsert por dia: soma ao existente
          final existing = await _isar.progressLogs.getByDay(log.day);
          if (existing != null) {
            existing.tasksCompleted += log.tasksCompleted;
            existing.pointsEarned += log.pointsEarned;
            // Mantém a maior streak
            if (log.currentStreak > existing.currentStreak) {
              existing.currentStreak = log.currentStreak;
            }
            await _isar.progressLogs.put(existing);
          } else {
            log.id = Isar.autoIncrement;
            await _isar.progressLogs.putByDay(log);
          }
        } else {
          log.id = Isar.autoIncrement;
          await _isar.progressLogs.putByDay(log);
        }
      }
    });

    // Retorna as tarefas com os IDs finais (já atualizados pelo put)
    // para que o chamador possa agendar notificações.
    return data.tasks;
  }
}

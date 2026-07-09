import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/task_item.dart';
import '../../core/utils/share_code_codec.dart';

/// Camada de acesso a dados para compartilhamento de tarefas via código.
/// Apenas repositories e models importam isar_community diretamente.
class ShareRepository {
  Isar get _isar => IsarService.instance;

  /// Gera um código a partir das tarefas com os [ids] fornecidos.
  /// Retorna a string do código (Base64 URL-safe) ou null se nenhuma
  /// tarefa for encontrada.
  Future<String?> exportSelected(Set<int> ids) async {
    if (ids.isEmpty) return null;

    final tasks = <TaskItem>[];
    for (final id in ids) {
      final task = await _isar.taskItems.get(id);
      if (task != null) tasks.add(task);
    }

    if (tasks.isEmpty) return null;
    return encodeTasks(tasks);
  }

  /// Decodifica um código e retorna a lista de tarefas para pré-visualização
  /// (sem salvar no banco).
  List<TaskItem> previewFromCode(String code) {
    return decodeTasks(code);
  }

  /// Importa tarefas já decodificadas para o banco local.
  /// Retorna o número de tarefas importadas com sucesso.
  Future<int> importTasks(List<TaskItem> tasks) async {
    if (tasks.isEmpty) return 0;

    var count = 0;
    await _isar.writeTxn(() async {
      for (final task in tasks) {
        // Garante que ids sejam auto-incrementados
        task.id = Isar.autoIncrement;
        await _isar.taskItems.put(task);
        count++;
      }
    });
    return count;
  }

  /// Importa tarefas de um [code] (Base64 URL-safe) para o banco local.
  /// Retorna o número de tarefas importadas com sucesso.
  Future<int> importFromCode(String code) async {
    final tasks = decodeTasks(code);
    if (tasks.isEmpty) return 0;
    return importTasks(tasks);
  }
}

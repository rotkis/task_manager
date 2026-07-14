import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task_item.dart';
import '../models/progress_log.dart';
import '../models/sub_task_item.dart';

/// Handler para a ação "Concluir" na notificação.
///
/// Executa em um **isolate de background** gerenciado pelo
/// `flutter_local_notifications`. Abre uma instância própria do Isar (não usa
/// o singleton do isolate principal), marca a tarefa como concluída e atualiza
/// o [ProgressLog] do dia.
///
/// ## Limitações
/// - Não depende de nenhum controller ou widget — é auto-contido.
/// - Se o Isar não puder ser aberto (ex: falta de permissão), a operação é
///   abortada silenciosamente com um `debugPrint`.
///
/// ## Como testar manualmente
/// 1. Criar uma tarefa com horário agendado (ex: daqui a 2 minutos).
/// 2. Fechar o app (remover da lista de recentes).
/// 3. Aguardar a notificação aparecer.
/// 4. Deslizar a notificação para revelar as ações → tocar **Concluir**.
/// 5. Reabrir o app → a tarefa deve aparecer em "Concluídas" e o gráfico de
///    evolução deve refletir o acréscimo de pontos.
@pragma('vm:entry-point')
void handleBackgroundCompleteTask(NotificationResponse response) {
  // Só processa a ação específica "Concluir"
  if (response.actionId != 'COMPLETE_TASK') return;

  final taskId = int.tryParse(response.payload ?? '');
  if (taskId == null) return;

  // Dispara o processamento assíncrono; o isolate mantém-se vivo
  // até a Future completar graças ao registro do callback pelo plugin.
  _processCompleteInBackground(taskId);
}

Future<void> _processCompleteInBackground(int taskId) async {
  Isar? isar;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final isarInstance = await Isar.open(
      [TaskItemSchema, ProgressLogSchema, SubTaskItemSchema],
      directory: dir.path,
    );
    isar = isarInstance;

    final task = await isarInstance.taskItems.get(taskId);
    if (task == null || task.isCompleted) return;

    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.postponeCount = 0;

    await isarInstance.writeTxn(() async {
      await isarInstance.taskItems.put(task);

      // Atualiza ProgressLog do dia
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final existingLog = await isarInstance.progressLogs
          .filter()
          .dayEqualTo(today)
          .findFirst();
      final log = existingLog ?? ProgressLog()
        ..day = today
        ..tasksCompleted = 0
        ..pointsEarned = 0
        ..currentStreak = 0;

      log.tasksCompleted += 1;
      log.pointsEarned += task.rewardPoints;

      // Cálculo de streak
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayLog = await isarInstance.progressLogs
          .filter()
          .dayEqualTo(yesterday)
          .findFirst();
      if (yesterdayLog != null && yesterdayLog.tasksCompleted > 0) {
        log.currentStreak = yesterdayLog.currentStreak + 1;
      } else {
        log.currentStreak = 1;
      }

      await isarInstance.progressLogs.put(log);
    });
  } catch (e) {
    // Não lança exceção para fora do callback de background
    debugPrint(
      '[BackgroundNotificationHandler] Erro ao completar tarefa $taskId: $e',
    );
  } finally {
    await isar?.close();
  }
}

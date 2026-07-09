import 'package:alarm/alarm.dart';

import '../../data/models/task_item.dart';

/// Wrapper do pacote `alarm` (gdelataillade).
///
/// Usado para tarefas **importantes** (`isImportant == true`) — toca áudio
/// em loop, vibra e dispara uma notificação persistente até o usuário parar
/// manualmente.
///
/// ## Permissões (Android)
/// O pacote `alarm` gerencia internamente as permissões necessárias:
/// - `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` (Android 12+/14+) — solicitada
///   automaticamente pelo [Alarm.set] quando necessário.
/// - `POST_NOTIFICATIONS` (Android 13+) — a notificação do alarme é tratada
///   pelo pacote.
/// - **Otimização de bateria** — o pacote exibe o diálogo de desativação
///   automaticamente se o alarme não puder ser agendado devido a restrições
///   de bateria.
///
/// Além disso, as permissões devem estar declaradas no `AndroidManifest.xml`
/// (ver `android/app/src/main/AndroidManifest.xml`).
class AlarmService {
  bool _initialized = false;

  /// Inicializa o serviço de alarme. Deve ser chamado uma vez no `main()`.
  Future<void> init() async {
    if (_initialized) return;
    await Alarm.init();
    _initialized = true;
  }

  /// Agenda um alarme para o horário definido em [task].
  ///
  /// Usa o [TaskItem.id] como identificador do alarme. Se a tarefa já
  /// possuir um `alarmId`, o alarme anterior é cancelado antes.
  Future<void> schedule(TaskItem task) async {
    if (!_initialized) await init();
    if (task.scheduledDate == null || task.scheduledTime == null) return;

    final scheduledDateTime = DateTime(
      task.scheduledDate!.year,
      task.scheduledDate!.month,
      task.scheduledDate!.day,
      task.scheduledTime!.hour,
      task.scheduledTime!.minute,
    );

    // Cancela alarme anterior se existir
    if (task.alarmId != null) {
      await cancel(task.alarmId!);
    }

    final alarmId = task.id;
    task.alarmId = alarmId;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: scheduledDateTime,
      loopAudio: true,
      vibrate: true,
      volumeSettings: const VolumeSettings.fixed(
        volume: 0.8,
      ),
      notificationSettings: NotificationSettings(
        title: task.title,
        body: task.description ?? 'Tarefa importante!',
        stopButton: 'Parar',
      ),
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Cancela o alarme com [alarmId].
  Future<void> cancel(int alarmId) async {
    await Alarm.stop(alarmId);
  }

  /// Cancela todos os alarmes agendados.
  Future<void> cancelAll() async {
    await Alarm.stopAll();
  }
}

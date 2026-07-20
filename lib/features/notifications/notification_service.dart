import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_item.dart';
import '../../data/repositories/background_notification_handler.dart';

/// Wrapper do pacote `flutter_local_notifications`.
///
/// Usado para tarefas **não importantes** — dispara notificações simples
/// no horário agendado (e opcionalmente em série se a tarefa tiver
/// [TaskItem.reminderRepeatMinutes] preenchido).
class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  /// Inicializa o plugin de notificações. Deve ser chamado uma vez no
  /// `main()` do app.
  Future<void> init() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin!.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: handleBackgroundCompleteTask,
    );
    _initialized = true;
  }

  /// Calcula quantas notificações devem ser agendadas para uma tarefa
  /// com repetição de [intervalMinutes] minutos a partir de
  /// [scheduledDateTime].
  ///
  /// Respeita o teto de até o fim do dia da tarefa (23:59).
  /// O número mínimo é 1 (pelo menos a notificação inicial).
  /// O teto de segurança é 96 (24 horas a cada 15 min, suficiente para
  /// qualquer intervalo praticável).
  @visibleForTesting
  static int repeatCount(int intervalMinutes, DateTime scheduledDateTime) {
    if (intervalMinutes <= 0) return 1;
    final endOfDay = DateTime(
      scheduledDateTime.year,
      scheduledDateTime.month,
      scheduledDateTime.day,
      23,
      59,
    );
    final totalMinutes = endOfDay.difference(scheduledDateTime).inMinutes;
    if (totalMinutes <= 0) return 1;
    final count = (totalMinutes / intervalMinutes).ceil();
    return count.clamp(1, 96);
  }

  /// Retorna a lista de IDs de notificação para a série de [task].
  ///
  /// Se [reminderRepeatMinutes] não estiver preenchido, retorna uma lista
  /// com um único elemento (`task.id`), mantendo o comportamento atual.
  ///
  /// Quando há repetição, os IDs seguem o padrão `task.id * 1000 + i`,
  /// onde `i` é o índice da repetição (0 = primeira notificação).
  /// Isso garante que cada notificação da série tenha um ID único e
  /// deterministicamente recalculável para cancelamento em lote.
  @visibleForTesting
  static List<int> notificationIdsForTask(TaskItem task) {
    final interval = task.reminderRepeatMinutes;
    if (interval == null || interval <= 0) return [task.id];
    if (task.scheduledDate == null || task.scheduledTime == null) {
      return [task.id];
    }
    final scheduledDateTime = DateTime(
      task.scheduledDate!.year,
      task.scheduledDate!.month,
      task.scheduledDate!.day,
      task.scheduledTime!.hour,
      task.scheduledTime!.minute,
    );
    final count = repeatCount(interval, scheduledDateTime);
    return List.generate(count, (i) => task.id * 1000 + i);
  }

  /// Agenda notificação(ões) para [task].
  ///
  /// Se [TaskItem.reminderRepeatMinutes] estiver preenchido, agendA uma
  /// SÉRIE de notificações espaçadas pelo intervalo escolhido, do horário
  /// da tarefa até o fim do dia (23:59).  Cada notificação usa um
  /// [notificationId] derivado de [task.id] para não colidir com outras
  /// tarefas.
  ///
  /// Cancela qualquer notificação anterior da mesma tarefa antes de
  /// agendar (via [cancelSeries]).
  Future<void> schedule(TaskItem task) async {
    if (!_initialized) await init();
    if (task.scheduledDate == null || task.scheduledTime == null) return;

    // Solicita permissão na primeira vez que agenda
    await requestPermissions();

    final baseDateTime = DateTime(
      task.scheduledDate!.year,
      task.scheduledDate!.month,
      task.scheduledDate!.day,
      task.scheduledTime!.hour,
      task.scheduledTime!.minute,
    );

    // Cancela notificações anteriores antes de agendar as novas
    await cancelSeries(task);

    final ids = notificationIdsForTask(task);
    final interval = task.reminderRepeatMinutes ?? 0;

    for (int i = 0; i < ids.length; i++) {
      final notificationId = ids[i];
      final scheduledDateTime =
          baseDateTime.add(Duration(minutes: interval * i));

      final isRepeat = i > 0;
      final body = isRepeat
          ? '${task.description ?? 'Você tem uma tarefa para fazer'} (repetição)'
          : (task.description ?? 'Você tem uma tarefa para fazer');

      final actionButtons = [
        const AndroidNotificationAction(
          'COMPLETE_TASK',
          'Concluir',
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ];
      final androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Notifications for scheduled tasks',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        actions: actionButtons,
      );
      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);

      debugPrint('''
━━━ [NotificationService] schedule() — repeat #$i ━━━
task.id:          ${task.id}
task.title:       ${task.title}
notificationId:   $notificationId
scheduledDateTime local: $scheduledDateTime
tzScheduled:      $tzScheduled
diff (s):         ${tzScheduled.difference(tz.TZDateTime.now(tz.local)).inSeconds}s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');

      try {
        await _plugin!.zonedSchedule(
          notificationId,
          task.title,
          body,
          tzScheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.exact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id.toString(),
        );
      } catch (e, stack) {
        debugPrint('''
━━━ [NotificationService] zonedSchedule EXCEPTION (repeat #$i) ━━━
task.id:       ${task.id}
notificationId: $notificationId
Exception:     $e
Stack trace:  $stack
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');
        rethrow;
      }
    }

    // Armazena o primeiro ID da série como referência
    task.notificationId = ids.isNotEmpty ? ids.first : null;

    // Verifica se as notificações foram registradas
    final pending = await _plugin!.pendingNotificationRequests();
    debugPrint('''
━━━ [NotificationService] pendingNotificationRequests ━━━
Total pending: ${pending.length}
${pending.map((r) => '  id=${r.id} title="${r.title}" body="${r.body}"').join('\n')}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');
  }

  /// Solicita permissão de notificação no Android 13+.
  ///
  /// No iOS não é necessário chamar explicitamente (o sistema pergunta
  /// na inicialização do plugin).
  Future<void> requestPermissions() async {
    if (!_initialized) await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin?.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  /// Agenda uma notificação de resumo semanal.
  ///
  /// Usa um canal separado (`weekly_summary_channel`) sem botões de ação.
  /// Cancela qualquer notificação anterior com o mesmo [id] antes de agendar.
  Future<void> scheduleWeeklySummary(
    int id,
    String title,
    String body,
    DateTime scheduledDateTime,
  ) async {
    if (!_initialized) await init();
    await requestPermissions();
    await cancel(id);

    final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'weekly_summary_channel',
      'Resumo Semanal',
      channelDescription: 'Resumo semanal de tarefas concluídas',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin!.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela a notificação com [notificationId].
  Future<void> cancel(int notificationId) async {
    if (_plugin == null) return;
    await _plugin!.cancel(notificationId);
  }

  /// Cancela TODAS as notificações da série de [task], não só a primeira.
  ///
  /// Usa [notificationIdsForTask] para recalcular deterministicamente
  /// todos os IDs que podem ter sido agendados para esta tarefa.
  Future<void> cancelSeries(TaskItem task) async {
    final ids = notificationIdsForTask(task);
    for (final id in ids) {
      await cancel(id);
    }
  }

  /// Agenda uma notificação de teste [seconds] no futuro para diagnosticar
  /// se o mecanismo de `zonedSchedule` está funcionando no dispositivo.
  ///
  /// Usa um id fixo alto (2³¹-2) para não conflitar com ids de tarefas.
  Future<void> scheduleDebugTest({int seconds = 30}) async {
    if (!_initialized) await init();
    await requestPermissions();

    const debugId = 2147483646; // max int32 - 1
    await cancel(debugId);

    final testMoment = DateTime.now().add(Duration(seconds: seconds));
    final tzTestMoment = tz.TZDateTime.from(testMoment, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    debugPrint('''
━━━ [NotificationService] scheduleDebugTest() ━━━
seconds:          $seconds
testMoment:       $testMoment
tz.local:         ${tz.local.name}
tzTestMoment:     $tzTestMoment
diff (s):         ${tzTestMoment.difference(tz.TZDateTime.now(tz.local)).inSeconds}s
debugId:          $debugId
mode:             ${AndroidScheduleMode.exact}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');

    await _plugin!.zonedSchedule(
      debugId,
      '🔔 Teste de agendamento',
      'Se você está vendo isto, o zonedSchedule funciona! '
          '(${DateTime.now().second}s)',
      tzTestMoment,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final pending = await _plugin!.pendingNotificationRequests();
    debugPrint('''
━━━ [NotificationService] debugTest pending ━━━
Total pending: ${pending.length}
${pending.map((r) => '  id=${r.id} title="${r.title}" body="${r.body}"').join('\n')}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');
  }

  /// Cancela todas as notificações agendadas.
  Future<void> cancelAll() async {
    if (_plugin == null) return;
    await _plugin!.cancelAll();
  }
}

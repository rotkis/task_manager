import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/task_item.dart';

/// Wrapper do pacote `flutter_local_notifications`.
///
/// Usado para tarefas **não importantes** — dispara uma notificação simples
/// no horário agendado.
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

    await _plugin!.initialize(initSettings);
    _initialized = true;
  }

  /// Agenda uma notificação para o horário definido em [task].
  ///
  /// Usa o [TaskItem.id] como identificador da notificação. Se a tarefa já
  /// possuir um `notificationId`, a notificação anterior é cancelada antes.
  Future<void> schedule(TaskItem task) async {
    if (!_initialized) await init();
    if (task.scheduledDate == null || task.scheduledTime == null) return;

    // Solicita permissão na primeira vez que agenda
    await requestPermissions();

    final scheduledDateTime = DateTime(
      task.scheduledDate!.year,
      task.scheduledDate!.month,
      task.scheduledDate!.day,
      task.scheduledTime!.hour,
      task.scheduledTime!.minute,
    );

    // Cancela notificação anterior se existir
    if (task.notificationId != null) {
      await cancel(task.notificationId!);
    }

    final notificationId = task.id;
    task.notificationId = notificationId;

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
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // ─── Log de depuração ─────────────────────────────────────────
    final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);
    debugPrint('''
━━━ [NotificationService] schedule() ━━━
task.id:          ${task.id}
task.title:       ${task.title}
scheduledDateTime local: $scheduledDateTime
scheduledDateTime ms:    ${scheduledDateTime.millisecondsSinceEpoch}
tz.local:         ${tz.local.name}
tzScheduled:      $tzScheduled
tzScheduled ms:   ${tzScheduled.millisecondsSinceEpoch}
now local:        ${DateTime.now()}
now ms:           ${DateTime.now().millisecondsSinceEpoch}
diff (s):         ${tzScheduled.difference(tz.TZDateTime.now(tz.local)).inSeconds}s
notificationId:   $notificationId
channel:          task_channel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');

    await _plugin!.zonedSchedule(
      notificationId,
      task.title,
      task.description ?? 'Você tem uma tarefa para fazer',
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // ─── Verifica se a notificação foi registrada ────────────
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

  /// Cancela a notificação com [notificationId].
  Future<void> cancel(int notificationId) async {
    if (_plugin == null) return;
    await _plugin!.cancel(notificationId);
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

    // Usamos alarmClock (AlarmManager.setAlarmClock) para testar se o
    // problema é específico do setExact() ou mais geral.
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

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
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
    tz.initializeTimeZones();

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
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin!.zonedSchedule(
      notificationId,
      task.title,
      task.description ?? 'Você tem uma tarefa para fazer',
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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

  /// Cancela todas as notificações agendadas.
  Future<void> cancelAll() async {
    if (_plugin == null) return;
    await _plugin!.cancelAll();
  }
}

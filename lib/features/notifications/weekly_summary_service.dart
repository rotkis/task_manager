/// Serviço de resumo semanal.
///
/// Calcula o resumo da semana (tarefas concluídas, pontos, streak,
/// comparação com a semana anterior) e agenda uma notificação
/// recorrente para domingo às 20:00 via [NotificationService].
library;

import 'dart:async';

import '../../data/models/progress_log.dart';
import '../../data/repositories/progress_repository.dart';
import '../../core/utils/date_helpers.dart';
import 'notification_service.dart';

/// Identificador fixo da notificação de resumo semanal.
///
/// Valor alto (2³¹-3) para não conflitar com ids de tarefas nem com o
/// debugId do [NotificationService].
const int weeklySummaryNotificationId = 2147483645;

/// Dados calculados do resumo semanal.
class WeeklySummary {
  const WeeklySummary({
    required this.tasksCompleted,
    required this.pointsEarned,
    required this.currentStreak,
    required this.tasksCompletedLastWeek,
  });

  /// Total de tarefas concluídas nesta semana.
  final int tasksCompleted;

  /// Total de pontos ganhos nesta semana.
  final int pointsEarned;

  /// Streak atual (dias seguidos com ≥1 tarefa concluída).
  final int currentStreak;

  /// Total de tarefas concluídas na semana anterior (para comparação).
  final int tasksCompletedLastWeek;

  /// Diferença em relação à semana passada (positivo = mais, negativo = menos).
  int get tasksDiff => tasksCompleted - tasksCompletedLastWeek;

  /// Constrói o corpo da notificação.
  String formatBody() {
    final diffStr = switch (tasksDiff) {
      > 0 => '+$tasksDiff',
      < 0 => '$tasksDiff',
      _ => 'mesmo número',
    };

    return '''📊 Resumo Semanal

Tarefas concluídas: $tasksCompleted
Pontos ganhos: $pointsEarned
Streak atual: 🔥 $currentStreak ${currentStreak == 1 ? 'dia' : 'dias'}

Comparado à semana passada: $diffStr tarefa${tasksDiff.abs() == 1 ? '' : 's'}''';
  }
}

/// Serviço que calcula o resumo semanal e agenda a notificação.
class WeeklySummaryService {
  WeeklySummaryService({
    required ProgressRepository progressRepository,
    required NotificationService notificationService,
  })  : _progressRepo = progressRepository,
        _notificationService = notificationService;

  final ProgressRepository _progressRepo;
  final NotificationService _notificationService;

  /// Re-agenda a notificação de resumo semanal para o próximo domingo
  /// às 20:00, substituindo qualquer agendamento anterior.
  ///
  /// Deve ser chamado uma vez na inicialização do app (ex: no `main()`).
  Future<void> scheduleNext() async {
    final nextSunday = _nextSundayAt2000();
    final thisWeekMonday = _mondayOfWeek(nextSunday);
    final thisWeekEnd = DateHelpers.normalizeToDay(nextSunday);

    // Semana anterior
    final lastWeekStart = thisWeekMonday.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekEnd.subtract(const Duration(days: 7));

    // Busca dados (one-shot via stream)
    final thisWeekLogs = await _fetchRange(thisWeekMonday, thisWeekEnd);
    final lastWeekLogs = await _fetchRange(lastWeekStart, lastWeekEnd);

    final summary = computeSummary(thisWeekLogs, lastWeekLogs);

    await _notificationService.scheduleWeeklySummary(
      weeklySummaryNotificationId,
      'Resumo Semanal',
      summary.formatBody(),
      nextSunday,
    );
  }

  /// Calcula o resumo a partir dos logs das duas semanas.
  ///
  /// Separado do resto para ser testável isoladamente.
  static WeeklySummary computeSummary(
    List<ProgressLog> thisWeek,
    List<ProgressLog> lastWeek,
  ) {
    final tasksCompleted =
        thisWeek.fold<int>(0, (sum, l) => sum + l.tasksCompleted);
    final pointsEarned =
        thisWeek.fold<int>(0, (sum, l) => sum + l.pointsEarned);

    // Streak: usa o último log da semana que tiver tasksCompleted > 0
    final logsWithTasks = thisWeek.where((l) => l.tasksCompleted > 0).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    final currentStreak =
        logsWithTasks.isNotEmpty ? logsWithTasks.last.currentStreak : 0;

    final tasksCompletedLastWeek =
        lastWeek.fold<int>(0, (sum, l) => sum + l.tasksCompleted);

    return WeeklySummary(
      tasksCompleted: tasksCompleted,
      pointsEarned: pointsEarned,
      currentStreak: currentStreak,
      tasksCompletedLastWeek: tasksCompletedLastWeek,
    );
  }

  /// Retorna o próximo domingo às 20:00 no fuso horário local.
  ///
  /// Se hoje é domingo e ainda são menos de 20:00, retorna hoje às 20:00.
  /// Caso contrário, retorna o domingo da semana seguinte.
  DateTime _nextSundayAt2000() {
    final now = DateTime.now();
    final today = DateHelpers.normalizeToDay(now);
    final weekday = now.weekday;

    int daysUntilSunday;
    if (weekday == DateTime.sunday) {
      final currentMinutes = now.hour * 60 + now.minute;
      if (currentMinutes <= 20 * 60) {
        daysUntilSunday = 0;
      } else {
        daysUntilSunday = 7;
      }
    } else {
      daysUntilSunday = DateTime.sunday - weekday;
    }

    final sunday = today.add(Duration(days: daysUntilSunday));
    return DateTime(sunday.year, sunday.month, sunday.day, 20, 0);
  }

  /// Segunda-feira da semana que contém [date].
  DateTime _mondayOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysFromMonday = weekday - DateTime.monday;
    return DateHelpers.normalizeToDay(
      date.subtract(Duration(days: daysFromMonday)),
    );
  }

  /// Busca logs num intervalo (one-shot).
  Future<List<ProgressLog>> _fetchRange(DateTime start, DateTime end) async {
    return _progressRepo.watchRange(start, end).first;
  }
}

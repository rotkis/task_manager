import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../data/models/task_item.dart';

/// Centraliza a comunicação com os widgets de tela inicial do Android
/// (Módulo 12).
///
/// Salva dados no SharedPreferences do widget e dispara a atualização
/// dos providers:
/// - [TaskWidgetProvider] (tarefas de hoje + streak)
/// - [CalendarWidgetProvider] lê o PNG + dados de tarefas salvos
class WidgetDataService {
  // ─── Chaves SharedPreferences ──────────────────────────────────

  static const _pendingKey = 'pending_count';
  static const _streakKey = 'streak';
  static const _scheduleCountKey = 'schedule_count';
  static const _scheduleRowPrefix = 'schedule_';
  static const _calendarTaskDataPrefix = 'calendar_tasks_data_';

  // ─── Nome do provider no AndroidManifest.xml ───────────────────

  static const _taskWidgetClass = 'TaskWidgetProvider';

  /// Atualiza o widget de tarefas de hoje (pendentes + streak +
  /// lista de até 5 tarefas) e força a re-renderização.
  ///
  /// Salva no SharedPreferences:
  /// - `pending_count`, `streak` — contadores
  /// - `schedule_count` — total de tarefas pendentes hoje
  /// - `schedule_1` … `schedule_5` — `"HH:mm|Título"` ordenadas por horário
  Future<void> updateTaskWidget({
    required int pendingCount,
    required int streak,
    required List<TaskItem> pendingTasks,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(_pendingKey, '$pendingCount');
      await HomeWidget.saveWidgetData<String>(_streakKey, '$streak');

      // Ordena pendentes por horário (com horário primeiro)
      final sorted = List<TaskItem>.from(pendingTasks)
        ..sort((a, b) {
          if (a.scheduledTime != null && b.scheduledTime == null) return -1;
          if (a.scheduledTime == null && b.scheduledTime != null) return 1;
          if (a.scheduledTime != null && b.scheduledTime != null) {
            return a.scheduledTime!.compareTo(b.scheduledTime!);
          }
          return a.createdAt.compareTo(b.createdAt);
        });

      final count = sorted.length;
      await HomeWidget.saveWidgetData<String>(_scheduleCountKey, '$count');

      for (int i = 0; i < 5 && i < sorted.length; i++) {
        final task = sorted[i];
        final time = task.scheduledTime != null
            ? '${task.scheduledTime!.hour.toString().padLeft(2, '0')}:'
                '${task.scheduledTime!.minute.toString().padLeft(2, '0')}'
            : '';
        await HomeWidget.saveWidgetData<String>(
          '$_scheduleRowPrefix${i + 1}',
          '$time|${task.title}',
        );
      }

      await HomeWidget.updateWidget(androidName: _taskWidgetClass);
    } catch (_) {}
  }

  /// Salva os dados de tarefas de um mês para renderização do
  /// calendário pelo Kotlin ([CalendarImageRenderer]).
  ///
  /// O formato do JSON salvo é:
  /// ```json
  /// {"5": {"n": 3, "d": false}, "7": {"n": 1, "d": true}}
  /// ```
  /// onde a chave é o dia (string) e o valor contém:
  /// - `n`: número total de tarefas no dia
  /// - `d`: `true` se TODAS estiverem concluídas, `false` se alguma pendente
  /// O Kotlin lê e desenha bolinhas: verdes se `d=true`, roxas se `d=false`.
  /// Mostra no máximo 3 bolinhas + "+N" se houver mais de 3 tarefas no dia.
  Future<void> saveCalendarTaskData({
    required int year,
    required int month,
    required Map<int, ({int count, bool allDone})> daySummary,
  }) async {
    try {
      final map = <String, Map<String, dynamic>>{};
      for (final entry in daySummary.entries) {
        map[entry.key.toString()] = {
          'n': entry.value.count,
          'd': entry.value.allDone,
        };
      }
      final json = jsonEncode(map);
      await HomeWidget.saveWidgetData<String>(
        '$_calendarTaskDataPrefix${year}_$month',
        json,
      );
    } catch (_) {}
  }

  /// Lê de todos os widgets de calendário instalados quais meses
  /// estão sendo exibidos e retorna um conjunto de `"year_month"`.
  ///
  /// Inclui sempre o mês corrente como fallback.
  Future<Set<String>> getDisplayedCalendarMonths() async {
    final months = <String>{};
    try {
      final widgets = await HomeWidget.getInstalledWidgets();
      for (final w in widgets) {
        final className = w.androidClassName ?? '';
        if (!className.contains('CalendarWidgetProvider')) continue;
        final widgetId = w.androidWidgetId;
        if (widgetId == null) continue;
        final offsetStr = await HomeWidget.getWidgetData<String>(
          'calendar_month_offset_$widgetId',
        );
        final offset = int.tryParse(offsetStr ?? '') ?? 0;
        final now = DateTime.now();
        final target = DateTime(now.year, now.month + offset);
        months.add('${target.year}_${target.month}');
      }
    } catch (_) {}
    // Always include current month
    final now = DateTime.now();
    months.add('${now.year}_${now.month}');
    return months;
  }

  /// Dispara atualização de todos os widgets [CalendarWidgetProvider]
  /// instalados para que carreguem os PNGs recém-gerados.
  Future<void> refreshCalendarWidgets() async {
    try {
      await HomeWidget.updateWidget(androidName: 'CalendarWidgetProvider');
    } catch (_) {}
  }
}

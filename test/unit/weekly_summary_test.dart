import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/progress_log.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import 'package:task_manager/features/notifications/weekly_summary_service.dart';

/// Cria um [ProgressLog] para [day] com os valores informados.
ProgressLog _log({
  required DateTime day,
  int tasksCompleted = 0,
  int pointsEarned = 0,
  int currentStreak = 0,
}) {
  return ProgressLog()
    ..day = DateHelpers.normalizeToDay(day)
    ..tasksCompleted = tasksCompleted
    ..pointsEarned = pointsEarned
    ..currentStreak = currentStreak;
}

void main() {
  group('WeeklySummaryService — computeSummary', () {
    test('semana sem logs retorna zeros', () {
      final result = WeeklySummaryService.computeSummary([], []);

      expect(result.tasksCompleted, 0);
      expect(result.pointsEarned, 0);
      expect(result.currentStreak, 0);
      expect(result.tasksCompletedLastWeek, 0);
      expect(result.tasksDiff, 0);
    });

    test('semana com logs soma tasks e pontos corretamente', () {
      final thisWeek = [
        _log(day: DateTime(2026, 7, 13), tasksCompleted: 3, pointsEarned: 30),
        _log(day: DateTime(2026, 7, 14), tasksCompleted: 2, pointsEarned: 20),
        _log(day: DateTime(2026, 7, 15), tasksCompleted: 5, pointsEarned: 50),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, []);

      expect(result.tasksCompleted, 10);
      expect(result.pointsEarned, 100);
      expect(result.tasksCompletedLastWeek, 0);
    });

    test('streak pega o último valor da semana', () {
      final thisWeek = [
        _log(
          day: DateTime(2026, 7, 13),
          tasksCompleted: 3,
          currentStreak: 2,
        ),
        _log(
          day: DateTime(2026, 7, 14),
          tasksCompleted: 1,
          currentStreak: 3,
        ),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, []);

      expect(result.currentStreak, 3);
    });

    test('streak é 0 se nenhum dia teve tarefas', () {
      final thisWeek = [
        _log(day: DateTime(2026, 7, 13), tasksCompleted: 0, currentStreak: 0),
        _log(day: DateTime(2026, 7, 14), tasksCompleted: 0, currentStreak: 0),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, []);

      expect(result.currentStreak, 0);
    });

    test('tasksDiff positivo quando semana atual tem mais tarefas', () {
      final thisWeek = [
        _log(day: DateTime(2026, 7, 13), tasksCompleted: 10),
      ];
      final lastWeek = [
        _log(day: DateTime(2026, 7, 6), tasksCompleted: 4),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, lastWeek);

      expect(result.tasksDiff, 6);
    });

    test('tasksDiff negativo quando semana atual tem menos tarefas', () {
      final thisWeek = [
        _log(day: DateTime(2026, 7, 13), tasksCompleted: 3),
      ];
      final lastWeek = [
        _log(day: DateTime(2026, 7, 6), tasksCompleted: 7),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, lastWeek);

      expect(result.tasksDiff, -4);
    });

    test('tasksDiff zero quando semanas têm o mesmo número', () {
      final thisWeek = [
        _log(day: DateTime(2026, 7, 13), tasksCompleted: 5),
      ];
      final lastWeek = [
        _log(day: DateTime(2026, 7, 6), tasksCompleted: 5),
      ];

      final result = WeeklySummaryService.computeSummary(thisWeek, lastWeek);

      expect(result.tasksDiff, 0);
    });
  });

  group('WeeklySummary — formatBody', () {
    test('formata corpo com diferença positiva (+N)', () {
      const summary = WeeklySummary(
        tasksCompleted: 10,
        pointsEarned: 100,
        currentStreak: 5,
        tasksCompletedLastWeek: 7,
      );

      final body = summary.formatBody();

      expect(body, contains('Tarefas concluídas: 10'));
      expect(body, contains('Pontos ganhos: 100'));
      expect(body, contains('Streak atual: 🔥 5 dias'));
      expect(body, contains('Comparado à semana passada: +3 tarefas'));
    });

    test('formata corpo com diferença negativa', () {
      const summary = WeeklySummary(
        tasksCompleted: 3,
        pointsEarned: 30,
        currentStreak: 2,
        tasksCompletedLastWeek: 7,
      );

      final body = summary.formatBody();

      expect(body, contains('Comparado à semana passada: -4 tarefas'));
    });

    test('formata corpo com zero tarefas', () {
      const summary = WeeklySummary(
        tasksCompleted: 0,
        pointsEarned: 0,
        currentStreak: 0,
        tasksCompletedLastWeek: 0,
      );

      final body = summary.formatBody();

      expect(body, contains('Tarefas concluídas: 0'));
      expect(body, contains('Pontos ganhos: 0'));
      expect(body, contains('Streak atual: 🔥 0'));
      expect(body, contains('Comparado à semana passada: mesmo número'));
    });

    test('formata singular (1 dia, 1 tarefa)', () {
      const summary = WeeklySummary(
        tasksCompleted: 1,
        pointsEarned: 10,
        currentStreak: 1,
        tasksCompletedLastWeek: 0,
      );

      final body = summary.formatBody();

      expect(body, contains('Streak atual: 🔥 1 dia'));
      expect(body, contains('+1 tarefa'));
    });

    test('formata diferença mesma quantidade', () {
      const summary = WeeklySummary(
        tasksCompleted: 5,
        pointsEarned: 50,
        currentStreak: 3,
        tasksCompletedLastWeek: 5,
      );

      final body = summary.formatBody();

      expect(body, contains('Comparado à semana passada: mesmo número'));
    });
  });
}

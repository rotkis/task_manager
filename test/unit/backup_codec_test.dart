import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/core/utils/backup_codec.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/models/sub_task_item.dart';
import 'package:task_manager/data/models/progress_log.dart';

void main() {
  group('BackupCodec — encodeBackup → decodeBackup', () {
    test('round-trip ida e volta para lista vazia', () {
      final json = encodeBackup(tasks: [], subtasks: [], progressLogs: []);
      expect(json, isNotEmpty);

      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.version, kBackupVersion);
      expect(data.tasks, isEmpty);
      expect(data.subtasks, isEmpty);
      expect(data.progressLogs, isEmpty);
    });

    test('round-trip preserva todos os campos de uma TaskItem genérica', () {
      final original = TaskItem()
        ..id = 42 // será descartado e redefinido no decode
        ..title = 'Comprar pão'
        ..description = 'Padaria da esquina'
        ..type = TaskType.generic
        ..scheduledDate = DateTime(2026, 7, 15)
        ..scheduledTime = DateTime(2000, 1, 1, 8, 30)
        ..isCompleted = false
        ..isNotificationEnabled = true
        ..isImportant = false
        ..rewardPoints = 10
        ..tags = ['casa', 'compras']
        ..createdAt = DateTime(2026, 7, 14, 10, 0, 0);

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.tasks.length, 1);

      final decoded = data.tasks.first;
      // id é resetado para _isarAutoIncrement (0) no decode
      expect(decoded.title, original.title);
      expect(decoded.description, original.description);
      expect(decoded.type, original.type);
      expect(decoded.scheduledDate, original.scheduledDate);
      expect(decoded.scheduledTime, original.scheduledTime);
      expect(decoded.isCompleted, original.isCompleted);
      expect(decoded.isNotificationEnabled, original.isNotificationEnabled);
      expect(decoded.isImportant, original.isImportant);
      expect(decoded.rewardPoints, original.rewardPoints);
      expect(decoded.tags, original.tags);
      expect(decoded.createdAt, original.createdAt);
    });

    test('round-trip preserva campos opcionais nulos', () {
      final original = TaskItem()
        ..title = 'Sem data nem extras'
        ..type = TaskType.generic;

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.tasks.length, 1);

      final decoded = data.tasks.first;
      expect(decoded.title, 'Sem data nem extras');
      expect(decoded.description, isNull);
      expect(decoded.scheduledDate, isNull);
      expect(decoded.scheduledTime, isNull);
      expect(decoded.completedAt, isNull);
      expect(decoded.durationMinutes, isNull);
      expect(decoded.durationSeconds, isNull);
      expect(decoded.targetReps, isNull);
      expect(decoded.targetSets, isNull);
      expect(decoded.recurrenceRule, isNull);
      expect(decoded.parentRecurringId, isNull);
      expect(decoded.tags, isEmpty);
    });

    test('round-trip preserva todos os tipos de tarefa', () {
      const types = TaskType.values;
      final tasks = types
          .map((t) => TaskItem()
            ..title = 'Tarefa $t'
            ..type = t)
          .toList();

      final json = encodeBackup(tasks: tasks, subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.tasks.length, types.length);

      for (int i = 0; i < types.length; i++) {
        expect(data.tasks[i].type, types[i]);
      }
    });

    test('round-trip preserva pomodoroStudy com duração e campos específicos',
        () {
      final original = TaskItem()
        ..title = 'Estudar Matemática'
        ..description = 'Capítulo 3'
        ..type = TaskType.pomodoroStudy
        ..scheduledDate = DateTime(2026, 7, 10)
        ..scheduledTime = DateTime(2000, 1, 1, 14, 30)
        ..durationMinutes = 25
        ..rewardPoints = 15
        ..isImportant = true
        ..tags = ['faculdade'];

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.tasks.length, 1);

      final decoded = data.tasks.first;
      expect(decoded.type, TaskType.pomodoroStudy);
      expect(decoded.durationMinutes, 25);
      expect(decoded.durationSeconds, isNull);
      expect(decoded.isImportant, true);
      expect(decoded.tags, ['faculdade']);
    });

    test('round-trip preserva timedExercise com duração em segundos', () {
      final original = TaskItem()
        ..title = 'Prancha'
        ..type = TaskType.timedExercise
        ..durationSeconds = 60;

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.tasks.first.durationSeconds, 60);
    });

    test('round-trip preserva repsExercise com repetições e séries', () {
      final original = TaskItem()
        ..title = 'Flexão'
        ..type = TaskType.repsExercise
        ..targetReps = 10
        ..targetSets = 3;

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);
      expect(data, isNotNull);

      final decoded = data!.tasks.first;
      expect(decoded.targetReps, 10);
      expect(decoded.targetSets, 3);
    });

    test('round-trip preserva completedAt e isCompleted', () {
      final original = TaskItem()
        ..title = 'Feita'
        ..type = TaskType.generic
        ..isCompleted = true
        ..completedAt = DateTime(2026, 7, 13, 15, 30);

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);

      final decoded = data!.tasks.first;
      expect(decoded.isCompleted, true);
      expect(decoded.completedAt, original.completedAt);
    });

    test('round-trip preserva recurrenceRule e parentRecurringId', () {
      final original = TaskItem()
        ..title = 'Hábito diário'
        ..type = TaskType.generic
        ..recurrenceRule = 'daily'
        ..parentRecurringId = null;

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);

      expect(data!.tasks.first.recurrenceRule, 'daily');
      expect(data.tasks.first.parentRecurringId, isNull);
    });

    test('round-trip preserva postponeCount', () {
      final original = TaskItem()
        ..title = 'Adiada várias vezes'
        ..type = TaskType.generic
        ..postponeCount = 3;

      final json =
          encodeBackup(tasks: [original], subtasks: [], progressLogs: []);
      final data = decodeBackup(json);

      expect(data!.tasks.first.postponeCount, 3);
    });

    test('round-trip subtasks preserva todos os campos', () {
      final sub = SubTaskItem()
        ..id = 99
        ..parentTaskId = 1
        ..title = 'Passo 1'
        ..isCompleted = true
        ..order = 0
        ..type = TaskType.generic;

      final json = encodeBackup(tasks: [], subtasks: [sub], progressLogs: []);
      final data = decodeBackup(json);

      expect(data, isNotNull);
      expect(data!.subtasks.length, 1);

      final decoded = data.subtasks.first;
      expect(decoded.title, 'Passo 1');
      expect(decoded.parentTaskId, 1);
      expect(decoded.isCompleted, true);
      expect(decoded.order, 0);
      expect(decoded.type, TaskType.generic);
    });

    test('round-trip subtasks com campos específicos de tipo', () {
      final sub = SubTaskItem()
        ..parentTaskId = 1
        ..title = 'Exercício'
        ..type = TaskType.repsExercise
        ..targetReps = 10
        ..targetSets = 3;

      final json = encodeBackup(tasks: [], subtasks: [sub], progressLogs: []);
      final data = decodeBackup(json);

      final decoded = data!.subtasks.first;
      expect(decoded.type, TaskType.repsExercise);
      expect(decoded.targetReps, 10);
      expect(decoded.targetSets, 3);
    });

    test('round-trip progressLogs preserva todos os campos', () {
      final log = ProgressLog()
        ..id = 7
        ..day = DateTime(2026, 7, 14)
        ..tasksCompleted = 5
        ..pointsEarned = 50
        ..currentStreak = 3;

      final json = encodeBackup(tasks: [], subtasks: [], progressLogs: [log]);
      final data = decodeBackup(json);

      expect(data, isNotNull);
      expect(data!.progressLogs.length, 1);

      final decoded = data.progressLogs.first;
      expect(decoded.day, DateTime(2026, 7, 14));
      expect(decoded.tasksCompleted, 5);
      expect(decoded.pointsEarned, 50);
      expect(decoded.currentStreak, 3);
    });

    test('round-trip múltiplas tarefas, subtarefas e logs', () {
      final tasks = [
        TaskItem()
          ..title = 'Tarefa A'
          ..type = TaskType.generic,
        TaskItem()
          ..title = 'Tarefa B'
          ..type = TaskType.pomodoroStudy
          ..durationMinutes = 25,
      ];
      final subtasks = [
        SubTaskItem()
          ..parentTaskId = 1
          ..title = 'Sub A1'
          ..order = 0,
        SubTaskItem()
          ..parentTaskId = 2
          ..title = 'Sub B1'
          ..order = 0,
      ];
      final logs = [
        ProgressLog()
          ..day = DateTime(2026, 7, 13)
          ..tasksCompleted = 2
          ..pointsEarned = 20
          ..currentStreak = 1,
        ProgressLog()
          ..day = DateTime(2026, 7, 14)
          ..tasksCompleted = 3
          ..pointsEarned = 30
          ..currentStreak = 2,
      ];

      final json =
          encodeBackup(tasks: tasks, subtasks: subtasks, progressLogs: logs);
      final data = decodeBackup(json);

      expect(data, isNotNull);
      expect(data!.tasks.length, 2);
      expect(data.subtasks.length, 2);
      expect(data.progressLogs.length, 2);
    });

    test('decodeBackup com JSON inválido retorna null', () {
      expect(decodeBackup('{invalid}'), isNull);
      expect(decodeBackup(''), isNull);
      expect(decodeBackup('not json at all'), isNull);
    });

    test('decodeBackup com versão ausente retorna null', () {
      expect(decodeBackup('{}'), isNull);
    });

    test('encodeBackup contém campo version e exportedAt', () {
      final json = encodeBackup(tasks: [], subtasks: [], progressLogs: []);
      expect(json, contains('"version"'));
      expect(json, contains('"exportedAt"'));
    });

    test('encodeBackup usa formatação com indentação', () {
      final json = encodeBackup(tasks: [], subtasks: [], progressLogs: []);
      // JSON formatado tem quebras de linha
      expect(json, contains('\n'));
    });

    test('decodeBackup aceita versão >= 1 (forward-compat)', () {
      const json = '{"version": 2, "exportedAt": "2026-07-14T00:00:00", '
          '"tasks": [], "subtasks": [], "progressLogs": []}';
      final data = decodeBackup(json);
      expect(data, isNotNull);
      expect(data!.version, 2);
    });
  });
}

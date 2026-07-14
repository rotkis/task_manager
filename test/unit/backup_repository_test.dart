import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:task_manager/data/isar/isar_service.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/models/sub_task_item.dart';
import 'package:task_manager/data/models/progress_log.dart';
import 'package:task_manager/data/repositories/backup_repository.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/core/utils/backup_codec.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late BackupRepository backupRepo;
  late TaskRepository taskRepo;
  late ProgressRepository progressRepo;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    backupRepo = BackupRepository();
    taskRepo = TaskRepository();
    progressRepo = ProgressRepository();
  });

  tearDown(() async {
    await helper.close();
  });

  group('BackupRepository — exportAll / importAll', () {
    test('exportAll gera JSON válido quando não há dados', () async {
      final json = await backupRepo.exportAll();
      expect(json, isNotEmpty);
      expect(json, contains('"version"'));
    });

    test('importAll com replace substitui dados existentes', () async {
      // Dados iniciais
      await taskRepo.create(
        TaskItem()
          ..title = 'Original'
          ..type = TaskType.generic,
      );

      // Cria dados de backup
      final backupJson = encodeBackup(
        tasks: [
          TaskItem()
            ..title = 'Backup'
            ..type = TaskType.generic,
        ],
        subtasks: [],
        progressLogs: [],
      );

      await backupRepo.importAll(backupJson, merge: false);

      // Verifica: só deve ter a tarefa do backup
      final allTasks = await _getAllTasks();
      expect(allTasks.length, 1);
      expect(allTasks.first.title, 'Backup');
    });

    test('importAll com replace apaga subtarefas antigas', () async {
      final taskId = await taskRepo.create(
        TaskItem()
          ..title = 'Tarefa'
          ..type = TaskType.generic,
      );
      await taskRepo.addSubtask(
        SubTaskItem()
          ..parentTaskId = taskId
          ..title = 'Sub antiga',
      );

      final backupJson =
          encodeBackup(tasks: [], subtasks: [], progressLogs: []);
      await backupRepo.importAll(backupJson, merge: false);

      final allSubs = await _getAllSubtasks();
      expect(allSubs, isEmpty);
    });

    test('importAll com merge adiciona tarefas às existentes', () async {
      await taskRepo.create(
        TaskItem()
          ..title = 'Existente'
          ..type = TaskType.generic,
      );

      final backupJson = encodeBackup(
        tasks: [
          TaskItem()
            ..title = 'Importada'
            ..type = TaskType.generic,
        ],
        subtasks: [],
        progressLogs: [],
      );

      await backupRepo.importAll(backupJson, merge: true);

      final allTasks = await _getAllTasks();
      expect(allTasks.length, 2);
      final titles = allTasks.map((t) => t.title).toSet();
      expect(titles, contains('Existente'));
      expect(titles, contains('Importada'));
    });

    test('importAll com merge soma progress logs no mesmo dia', () async {
      final today = DateHelpers.today();

      // Cria log existente com 2 tarefas
      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.progressLogs.putByDay(
          ProgressLog()
            ..day = today
            ..tasksCompleted = 2
            ..pointsEarned = 20
            ..currentStreak = 1,
        );
      });

      final backupJson = encodeBackup(
        tasks: [],
        subtasks: [],
        progressLogs: [
          ProgressLog()
            ..day = today
            ..tasksCompleted = 3
            ..pointsEarned = 30
            ..currentStreak = 5, // maior streak
        ],
      );

      await backupRepo.importAll(backupJson, merge: true);

      final log = await progressRepo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.tasksCompleted, 5); // 2 + 3
      expect(log.pointsEarned, 50); // 20 + 30
      expect(log.currentStreak, 5); // manteve a maior (5 > 1)
    });

    test('importAll com merge adiciona progress logs de dias diferentes',
        () async {
      final day1 = DateTime(2026, 7, 10);
      final day2 = DateTime(2026, 7, 11);

      final backupJson = encodeBackup(
        tasks: [],
        subtasks: [],
        progressLogs: [
          ProgressLog()
            ..day = day1
            ..tasksCompleted = 1
            ..pointsEarned = 10
            ..currentStreak = 1,
          ProgressLog()
            ..day = day2
            ..tasksCompleted = 2
            ..pointsEarned = 20
            ..currentStreak = 2,
        ],
      );

      await backupRepo.importAll(backupJson, merge: true);

      final log1 = await progressRepo.getByDay(day1);
      expect(log1, isNotNull);
      expect(log1!.tasksCompleted, 1);

      final log2 = await progressRepo.getByDay(day2);
      expect(log2, isNotNull);
      expect(log2!.tasksCompleted, 2);
    });

    test('importAll com replace no lugar de merge apaga e recria', () async {
      final today = DateHelpers.today();

      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.progressLogs.putByDay(
          ProgressLog()
            ..day = today
            ..tasksCompleted = 99
            ..pointsEarned = 999
            ..currentStreak = 10,
        );
      });

      final backupJson = encodeBackup(
        tasks: [],
        subtasks: [],
        progressLogs: [
          ProgressLog()
            ..day = today
            ..tasksCompleted = 3
            ..pointsEarned = 30
            ..currentStreak = 1,
        ],
      );

      await backupRepo.importAll(backupJson, merge: false);

      final log = await progressRepo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.tasksCompleted, 3); // substituído, não somado
      expect(log.pointsEarned, 30);
      expect(log.currentStreak, 1);
    });

    test('importAll com invalid JSON lança FormatException', () async {
      await expectLater(
        () => backupRepo.importAll('{invalid}', merge: false),
        throwsFormatException,
      );
      await expectLater(
        () => backupRepo.importAll('{}', merge: false),
        throwsFormatException,
      );
    });

    test('exportAll + importAll round-trip preserva integridade dos dados',
        () async {
      // Cria dados originais
      final taskId = await taskRepo.create(
        TaskItem()
          ..title = 'Tarefa 1'
          ..type = TaskType.pomodoroStudy
          ..durationMinutes = 25
          ..rewardPoints = 15
          ..tags = ['estudo'],
      );
      await taskRepo.create(
        TaskItem()
          ..title = 'Tarefa 2'
          ..type = TaskType.repsExercise
          ..targetReps = 10
          ..targetSets = 3
          ..scheduledDate = DateTime(2026, 7, 20)
          ..scheduledTime = DateTime(2000, 1, 1, 14, 0)
          ..isImportant = true,
      );

      await taskRepo.addSubtask(
        SubTaskItem()
          ..parentTaskId = taskId
          ..title = 'Sub 1'
          ..order = 0,
      );

      // Exporta
      final json = await backupRepo.exportAll();

      // Limpa tudo
      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.taskItems.clear();
        await isar.subTaskItems.clear();
        await isar.progressLogs.clear();
      });

      // Importa
      await backupRepo.importAll(json, merge: false);

      // Verifica
      final allTasks = await _getAllTasks();
      expect(allTasks.length, 2);

      final allSubs = await _getAllSubtasks();
      expect(allSubs.length, 1);
      expect(allSubs.first.title, 'Sub 1');

      // Verifica que as subtarefas apontam para uma tarefa existente
      final parentTaskIds = allSubs.map((s) => s.parentTaskId).toSet();
      final taskIds = allTasks.map((t) => t.id).toSet();
      for (final parentId in parentTaskIds) {
        expect(taskIds, contains(parentId),
            reason: 'Subtask parentTaskId deve referenciar tarefa existente');
      }

      // Verifica campos específicos
      final pomodoroTask =
          allTasks.firstWhere((t) => t.type == TaskType.pomodoroStudy);
      expect(pomodoroTask.durationMinutes, 25);
      expect(pomodoroTask.tags, ['estudo']);

      final repsTask =
          allTasks.firstWhere((t) => t.type == TaskType.repsExercise);
      expect(repsTask.targetReps, 10);
      expect(repsTask.targetSets, 3);
      expect(repsTask.isImportant, true);
    });

    test('importAll com merge + subtarefas preserva referências', () async {
      // Cria uma tarefa com subtarefa e exporta
      final novaId = await taskRepo.create(
        TaskItem()
          ..title = 'Nova'
          ..type = TaskType.generic,
      );
      final subId = await taskRepo.addSubtask(
        SubTaskItem()
          ..parentTaskId = novaId
          ..title = 'Sub da nova'
          ..order = 0,
      );

      // Exporta
      final json = await backupRepo.exportAll();

      // Remove a tarefa e subtarefa (simula "perda de dados")
      await taskRepo.delete(novaId);
      await taskRepo.deleteSubtask(subId);

      // Importa com merge
      await backupRepo.importAll(json, merge: true);

      final allTasks = await _getAllTasks();
      expect(allTasks.length, 1);
      expect(allTasks.first.title, 'Nova');

      final allSubs = await _getAllSubtasks();
      expect(allSubs.length, 1);
      expect(allSubs.first.title, 'Sub da nova');

      // Verifica remapeamento: subtask.parentTaskId deve ser o id da nova tarefa
      final taskIds = allTasks.map((t) => t.id).toSet();
      expect(
        taskIds,
        contains(allSubs.first.parentTaskId),
        reason:
            'parentTaskId da subtarefa deve ser remapeado para o id correto',
      );
    });

    test(
        'importAll merge previne colisão de IDs: backup com id=1 não sobrescreve tarefa existente id=1',
        () async {
      // ── Banco atual já tem uma tarefa com id = 1 ──
      await taskRepo.create(
        TaskItem()
          ..title = 'Original'
          ..type = TaskType.generic,
      );

      // ── Backup tem OUTRA tarefa que também tem id = 1 ──
      final backupTask = TaskItem()
        ..id = 1 // mesmo id que a tarefa já existente
        ..title = 'Backup'
        ..type = TaskType.generic;
      final backupJson =
          encodeBackup(tasks: [backupTask], subtasks: [], progressLogs: []);

      // ── Importa com merge ──
      await backupRepo.importAll(backupJson, merge: true);

      // ── Verifica: ambas existem, com ids diferentes ──
      final allTasks = await _getAllTasks();
      expect(allTasks.length, 2,
          reason:
              'Deve haver 2 tarefas, não 1 (a original não foi sobrescrita)');

      final titles = allTasks.map((t) => t.title).toSet();
      expect(titles, contains('Original'));
      expect(titles, contains('Backup'));

      final ids = allTasks.map((t) => t.id).toSet();
      expect(ids.length, 2, reason: 'Os IDs devem ser diferentes entre si');

      // Nenhuma tarefa deve ter o id original do backup (1) após o remapeamento
      // porque a original já ocupa id=1.
      expect(allTasks.where((t) => t.id == 1).length, 1,
          reason: 'Deve existir exatamente 1 tarefa com id=1 (a original) — '
              'a do backup foi remapeada para outro id');
    });
  });
}

// ─── Helpers ────────────────────────────────────────────────────────────

Future<List<TaskItem>> _getAllTasks() async {
  final isar = IsarService.instance;
  return isar.taskItems.where().findAll();
}

Future<List<SubTaskItem>> _getAllSubtasks() async {
  final isar = IsarService.instance;
  return isar.subTaskItems.where().findAll();
}

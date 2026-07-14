import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late TaskRepository taskRepo;
  late ProgressRepository progressRepo;
  late TaskController controller;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    taskRepo = TaskRepository();
    progressRepo = ProgressRepository();
    controller = TaskController(taskRepo: taskRepo, progressRepo: progressRepo);
  });

  tearDown(() async {
    controller.dispose();
    await helper.close();
  });

  Future<int> createSampleTask({
    String title = 'Tarefa teste',
    int points = 10,
    bool isCompleted = false,
  }) async {
    final task = TaskItem()
      ..title = title
      ..type = TaskType.generic
      ..scheduledDate = DateHelpers.today()
      ..rewardPoints = points
      ..isCompleted = isCompleted;
    return taskRepo.create(task);
  }

  group('TaskController', () {
    test('createTask adiciona tarefa ao banco', () async {
      final task = TaskItem()
        ..title = 'Nova'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today();

      await controller.createTask(task);

      final all = await taskRepo.watchAll().first;
      expect(all.length, 1);
      expect(all.first.title, 'Nova');
    });

    test('updateTask modifica tarefa', () async {
      final id = await createSampleTask();
      final task = await taskRepo.getById(id) as TaskItem;
      task.title = 'Editada';
      await controller.updateTask(task);

      final updated = await taskRepo.getById(id);
      expect(updated!.title, 'Editada');
    });

    test('completeTask marca como concluída e registra progresso', () async {
      // Pré-condição: sem progresso hoje
      final today = DateHelpers.today();
      var log = await progressRepo.getByDay(today);
      expect(log, isNull);

      final id = await createSampleTask(points: 10);
      await controller.completeTask(id);

      // Tarefa concluída
      final task = await taskRepo.getById(id);
      expect(task!.isCompleted, true);
      expect(task.completedAt, isNotNull);

      // Progresso registrado
      log = await progressRepo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.tasksCompleted, 1);
      expect(log.pointsEarned, 10);
    });

    test('completeTask em tarefa já concluída não duplica pontos', () async {
      final id = await createSampleTask(points: 5, isCompleted: true);

      // Tentar concluir de novo
      await controller.completeTask(id);

      final today = DateHelpers.today();
      final log = await progressRepo.getByDay(today);
      expect(log, isNull); // Nenhum progresso foi criado
    });

    test('deleteTask + undoDelete restaura tarefa', () async {
      final id = await createSampleTask();
      expect(await taskRepo.getById(id), isNotNull);

      await controller.deleteTask(id);
      expect(await taskRepo.getById(id), isNull);

      await controller.undoDelete();
      // A tarefa foi recriada com novo id
      final all = await taskRepo.watchAll().first;
      expect(all.length, 1);
      expect(all.first.title, 'Tarefa teste');
    });

    test('listas pendentes e concluídas refletem estado correto', () async {
      // Cria 2 pendentes e 1 concluída
      await createSampleTask(title: 'Pendente A');
      await createSampleTask(title: 'Pendente B');
      final id3 = await createSampleTask(title: 'Concluída');
      await controller.completeTask(id3);

      // Controller precisa estar escutando para ter as listas atualizadas
      // Vamos iniciar a escuta manualmente
      controller.init();
      // Dá tempo para o stream emitir
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.pendingTasks.length, 2);
      expect(controller.completedTasks.length, 1);
      expect(controller.completedTasks.first.title, 'Concluída');
    });

    test('createTask com recurrenceRule gera instâncias futuras imediatamente',
        () async {
      // Arrange: criar uma tarefa-modelo recorrente para amanhã
      final today = DateHelpers.today();
      final tomorrow = today.add(const Duration(days: 1));
      final task = TaskItem()
        ..title = 'Hábito diário'
        ..type = TaskType.generic
        ..scheduledDate = tomorrow
        ..rewardPoints = 10
        ..recurrenceRule = 'daily';

      // Act
      await controller.createTask(task);

      // Assert: tarefa modelo foi salva
      final models = await taskRepo.getModelTasks();
      expect(models.length, 1, reason: 'deve existir 1 tarefa-modelo');
      expect(models.first.title, 'Hábito diário');
      expect(models.first.recurrenceRule, 'daily');

      // Assert: instância do dia seguinte existe (amanhã é a data do modelo,
      // então a primeira instância gerada é depois de amanhã)
      final dayAfter = tomorrow.add(const Duration(days: 1));
      final instances = await taskRepo.getInstancesInRange(
        models.first.id,
        dayAfter,
        dayAfter,
      );
      expect(instances.length, 1,
          reason:
              'deve existir instância para depois de amanhã imediatamente após createTask');
      expect(instances.first.title, 'Hábito diário');
      expect(instances.first.parentRecurringId, models.first.id);
      expect(instances.first.isCompleted, false,
          reason: 'instância futura não deve estar concluída');
    });
  });
}

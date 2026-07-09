import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late TaskRepository repo;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    repo = TaskRepository();
  });

  tearDown(() async {
    await helper.close();
  });

  group('TaskRepository — CRUD', () {
    test('create e getById retorna a tarefa criada', () async {
      final id = await repo.create(
        TaskItem()
          ..title = 'Minha tarefa'
          ..type = TaskType.generic,
      );
      expect(id, greaterThan(0));

      final retrieved = await repo.getById(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Minha tarefa');
    });

    test('update modifica campos da tarefa', () async {
      final task = TaskItem()
        ..title = 'Original'
        ..type = TaskType.generic;
      final id = await repo.create(task);
      task.id = id;
      task.title = 'Atualizada';
      await repo.update(task);

      final updated = await repo.getById(id);
      expect(updated!.title, 'Atualizada');
    });

    test('delete remove a tarefa', () async {
      final task = TaskItem()
        ..title = 'Para deletar'
        ..type = TaskType.generic;
      final id = await repo.create(task);
      await repo.delete(id);

      final deleted = await repo.getById(id);
      expect(deleted, isNull);
    });

    test('watchAll emite lista com todas as tarefas', () async {
      // Cria dados ANTES de escutar para evitar capturar lista vazia
      await repo.create(
        TaskItem()
          ..title = 'Primeira'
          ..type = TaskType.generic,
      );
      await repo.create(
        TaskItem()
          ..title = 'Segunda'
          ..type = TaskType.generic,
      );

      final tasks = await repo.watchAll().first;
      expect(tasks.length, 2);
    });

    test('watchPending filtra apenas tarefas não concluídas', () async {
      await repo.create(
        TaskItem()
          ..title = 'Pendente'
          ..type = TaskType.generic
          ..isCompleted = false,
      );
      await repo.create(
        TaskItem()
          ..title = 'Concluída'
          ..type = TaskType.generic
          ..isCompleted = true,
      );

      final pending = await repo.watchPending().first;
      expect(pending.length, 1);
      expect(pending.first.isCompleted, false);
      expect(pending.first.title, 'Pendente');
    });

    test('watchByDate retorna tarefas de um dia específico', () async {
      final today = DateHelpers.today();
      final tomorrow = today.add(const Duration(days: 1));

      await repo.create(
        TaskItem()
          ..title = 'Hoje'
          ..type = TaskType.generic
          ..scheduledDate = today,
      );
      await repo.create(
        TaskItem()
          ..title = 'Amanhã'
          ..type = TaskType.generic
          ..scheduledDate = tomorrow,
      );

      final todayTasks = await repo.watchByDate(today).first;
      expect(todayTasks.length, 1);
      expect(todayTasks.first.title, 'Hoje');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/sub_task_item.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
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

  group('TaskRepository — subtarefas CRUD', () {
    late int parentTaskId;

    setUp(() async {
      final task = TaskItem()
        ..title = 'Tarefa com subtarefas'
        ..type = TaskType.generic;
      parentTaskId = await repo.create(task);
    });

    test('addSubtask cria e retorna id', () async {
      final id = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Passo 1');
      expect(id, isNonZero);

      final subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks.length, 1);
      expect(subtasks[0].title, 'Passo 1');
      expect(subtasks[0].order, 0);
    });

    test('addSubtask múltiplas incrementa order', () async {
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'A');
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'B');

      final subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks.length, 2);
      expect(subtasks[0].title, 'A');
      expect(subtasks[0].order, 0);
      expect(subtasks[1].title, 'B');
      expect(subtasks[1].order, 1);
    });

    test('toggleSubtask alterna isCompleted', () async {
      final id = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Passo');

      // Inicialmente não concluída
      var subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks[0].isCompleted, false);

      // Alterna para concluída
      await repo.toggleSubtask(id);
      subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks[0].isCompleted, true);

      // Alterna de volta
      await repo.toggleSubtask(id);
      subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks[0].isCompleted, false);
    });

    test('deleteSubtask remove subtarefa', () async {
      final id = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Será removido');

      var subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks.length, 1);

      await repo.deleteSubtask(id);
      subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks, isEmpty);
    });

    test('reorderSubtasks atualiza order', () async {
      final idA = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'A'
        ..order = 0);
      final idB = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'B'
        ..order = 1);
      final idC = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'C'
        ..order = 2);

      // Reordena: C → A → B
      await repo.reorderSubtasks(parentTaskId, [idC, idA, idB]);

      final subtasks = await repo.getSubtasks(parentTaskId);
      expect(subtasks.length, 3);
      expect(subtasks[0].title, 'C');
      expect(subtasks[0].order, 0);
      expect(subtasks[1].title, 'A');
      expect(subtasks[1].order, 1);
      expect(subtasks[2].title, 'B');
      expect(subtasks[2].order, 2);
    });

    test('watchSubtasks emite lista inicial', () async {
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Passo');

      final stream = repo.watchSubtasks(parentTaskId);
      final emitted = await stream.first;
      expect(emitted.length, 1);
      expect(emitted[0].title, 'Passo');
    });

    test('watchSubtasks emite atualização após toggle', () async {
      final id = await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Passo');

      final sub = repo.watchSubtasks(parentTaskId).listen((list) {});
      addTearDown(sub.cancel);

      // Pega valor inicial
      final first = await repo.watchSubtasks(parentTaskId).first;
      expect(first[0].isCompleted, false);

      // Alterna e verifica
      await repo.toggleSubtask(id);

      // Aguarda o stream emitir
      final second = await repo
          .watchSubtasks(parentTaskId)
          .firstWhere((list) => list[0].isCompleted);
      expect(second[0].isCompleted, true);
    });

    test('subtasks de tarefas diferentes são independentes', () async {
      // Cria segunda tarefa
      final task2 = TaskItem()
        ..title = 'Outra tarefa'
        ..type = TaskType.generic;
      final pid2 = await repo.create(task2);

      // Adiciona subtarefas em cada uma
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = parentTaskId
        ..title = 'Subtarefa 1');
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = pid2
        ..title = 'Subtarefa 2');

      final st1 = await repo.getSubtasks(parentTaskId);
      final st2 = await repo.getSubtasks(pid2);

      expect(st1.length, 1);
      expect(st1[0].title, 'Subtarefa 1');
      expect(st2.length, 1);
      expect(st2[0].title, 'Subtarefa 2');
    });
  });
}

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

  group('TaskRepository — watchFiltered', () {
    TaskItem genericTask(String title,
        {TaskType type = TaskType.generic,
        bool isCompleted = false,
        String? description,
        DateTime? scheduledDate}) {
      return TaskItem()
        ..title = title
        ..description = description
        ..type = type
        ..isCompleted = isCompleted
        ..scheduledDate = scheduledDate;
    }

    test('sem filtros retorna todas as tarefas', () async {
      await repo.create(genericTask('A'));
      await repo.create(genericTask('B'));

      final result = await repo.watchFiltered().first;
      expect(result.length, 2);
    });

    test('filtro textual por título (case-insensitive)', () async {
      await repo.create(genericTask('Estudar Matemática'));
      await repo.create(genericTask('Fazer Compras'));
      await repo.create(genericTask('Estudar Física'));

      final result = await repo.watchFiltered(query: 'estudar').first;
      expect(result.length, 2);
      expect(result.every((t) => t.title.toLowerCase().contains('estudar')),
          isTrue);
    });

    test('filtro textual por descrição', () async {
      await repo.create(
          genericTask('Tarefa A', description: 'revisão de matemática'));
      await repo.create(
          genericTask('Tarefa B', description: 'compras no supermercado'));

      final result = await repo.watchFiltered(query: 'matemática').first;
      expect(result.length, 1);
      expect(result.first.title, 'Tarefa A');
    });

    test('filtro por tipo', () async {
      await repo.create(genericTask('Genérica'));
      await repo.create(genericTask('Pomodoro', type: TaskType.pomodoroStudy));
      await repo.create(genericTask('Timer', type: TaskType.timedExercise));

      final result =
          await repo.watchFiltered(type: TaskType.pomodoroStudy).first;
      expect(result.length, 1);
      expect(result.first.title, 'Pomodoro');
    });

    test('filtro por status concluído', () async {
      await repo.create(genericTask('Pendente', isCompleted: false));
      await repo.create(genericTask('Feita', isCompleted: true));

      final pendentes = await repo.watchFiltered(isCompleted: false).first;
      expect(pendentes.length, 1);
      expect(pendentes.first.title, 'Pendente');

      final concluidas = await repo.watchFiltered(isCompleted: true).first;
      expect(concluidas.length, 1);
      expect(concluidas.first.title, 'Feita');
    });

    test('filtro por intervalo de data', () async {
      final today = DateHelpers.today();
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      await repo.create(genericTask('Hoje', scheduledDate: today));
      await repo.create(genericTask('Amanhã', scheduledDate: tomorrow));
      await repo.create(genericTask('Semana que vem', scheduledDate: nextWeek));

      // Intervalo: hoje até amanhã (inclusive)
      final result =
          await repo.watchFiltered(dateStart: today, dateEnd: tomorrow).first;
      expect(result.length, 2);
      expect(result.map((t) => t.title), containsAll(['Hoje', 'Amanhã']));
    });

    test('filtros combinados (query + tipo + status)', () async {
      await repo.create(genericTask('Estudar Matemática',
          type: TaskType.pomodoroStudy, isCompleted: false));
      await repo.create(genericTask('Estudar Física',
          type: TaskType.pomodoroStudy, isCompleted: true));
      await repo.create(genericTask('Treino',
          type: TaskType.timedExercise, isCompleted: false));

      // Busca "estudar" + tipo pomodoro + pendente
      final result = await repo
          .watchFiltered(
              query: 'estudar',
              type: TaskType.pomodoroStudy,
              isCompleted: false)
          .first;
      expect(result.length, 1);
      expect(result.first.title, 'Estudar Matemática');
    });

    test('query vazia retorna todos os resultados sem filtrar texto', () async {
      await repo.create(genericTask('A'));
      await repo.create(genericTask('B'));

      final result = await repo.watchFiltered(query: '').first;
      expect(result.length, 2);
    });

    test('tarefa sem data com dateStart é incluída', () async {
      await repo.create(genericTask('Sem data'));
      await repo
          .create(genericTask('Com data', scheduledDate: DateHelpers.today()));

      final result =
          await repo.watchFiltered(dateStart: DateHelpers.today()).first;
      // Tarefa sem data também aparece (não tem scheduledDate para filtrar)
      expect(result.any((t) => t.title == 'Sem data'), isTrue);
    });

    test('isCompleted:false + dateEnd passado = tarefas de dias anteriores',
        () async {
      // ATENÇÃO: Este teste valida o comportamento do watchFiltered com
      // parâmetros de data. NÃO é equivalente ao filtro "Atrasadas" da UI,
      // que usa task.isOverdue (inclui tarefas de hoje com horário já
      // passado). O chip "Atrasadas" na tela filtra item a item, não via
      // watchFiltered.
      final today = DateHelpers.today();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      await repo.create(genericTask('Atrasada',
          scheduledDate: yesterday, isCompleted: false));
      await repo.create(genericTask('Concluída atrasada',
          scheduledDate: yesterday, isCompleted: true));
      await repo.create(
          genericTask('Futura', scheduledDate: tomorrow, isCompleted: false));

      final result = await repo
          .watchFiltered(isCompleted: false, dateEnd: yesterday)
          .first;

      expect(result.length, 1);
      expect(result.first.title, 'Atrasada');
    });
  });
}

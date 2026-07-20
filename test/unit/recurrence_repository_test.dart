import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/models/sub_task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late TaskRepository repo;

  // Data de referência fixa: segunda-feira, 20 de julho de 2026.
  // Usar uma data fixa em vez de DateTime.now() evita flakiness
  // quando os testes são executados em dias com semana diferentes.
  final kToday = DateTime(2026, 7, 20);

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    repo = TaskRepository();
  });

  tearDown(() async {
    await helper.close();
  });

  group('TaskRepository — ensureUpcomingInstances', () {
    test('cria instâncias diárias para os próximos 30 dias', () async {
      // Cria um modelo com recorrência diária
      final model = TaskItem()
        ..title = 'Meditar'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'daily'
        ..scheduledDate = kToday;
      await repo.create(model);

      // Gera instâncias
      await repo.ensureUpcomingInstances(
        daysAhead: 30,
        referenceDate: kToday,
      );

      // Verifica que foram criadas instâncias para os próximos 30 dias
      // (o dia do modelo não é duplicado como instância)
      final instances = await repo.getInstancesInRange(
        model.id,
        kToday.subtract(const Duration(days: 1)),
        kToday.add(const Duration(days: 31)),
      );
      expect(instances.length, 30); // 30 dias futuros (modelo já cobre hoje)

      // Todas apontam para o modelo
      for (final inst in instances) {
        expect(inst.parentRecurringId, model.id);
        expect(inst.recurrenceRule, isNull); // instância não é modelo
        expect(inst.title, 'Meditar');
      }
    });

    test('não duplica instâncias já existentes', () async {
      final model = TaskItem()
        ..title = 'Exercício'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'daily'
        ..scheduledDate = kToday;
      await repo.create(model);

      // Primeira geração
      await repo.ensureUpcomingInstances(
        daysAhead: 5,
        referenceDate: kToday,
      );
      final firstGen = await repo.getInstancesInRange(
        model.id,
        kToday.subtract(const Duration(days: 1)),
        kToday.add(const Duration(days: 6)),
      );
      expect(firstGen.length, 5); // 5 dias futuros (modelo já cobre hoje)

      // Segunda geração (mesmo período)
      await repo.ensureUpcomingInstances(
        daysAhead: 5,
        referenceDate: kToday,
      );
      final secondGen = await repo.getInstancesInRange(
        model.id,
        kToday.subtract(const Duration(days: 1)),
        kToday.add(const Duration(days: 6)),
      );
      expect(secondGen.length, 5); // ainda 5, sem duplicatas
    });

    test('cria instâncias semanais nos dias corretos', () async {
      // Segunda(1), Quarta(3), Sexta(5)
      // kToday = 2026-07-20 (Monday)
      final model = TaskItem()
        ..title = 'Estudar'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'weekly:MO,WE,FR'
        ..scheduledDate = kToday; // Monday
      await repo.create(model);

      // Gera instâncias
      await repo.ensureUpcomingInstances(
        daysAhead: 13,
        referenceDate: kToday,
      );

      // Intervalo: do dia do modelo até 14 dias depois
      final instances = await repo.getInstancesInRange(
        model.id,
        kToday,
        kToday.add(const Duration(days: 14)),
      );

      // kToday(Mon,modelo) + 22(Wed) + 24(Fri) + 27(Mon) + 29(Wed) + 31(Fri) = 6 datas
      // Modelo excluído → 5 instâncias (22, 24, 27, 29, 31)
      expect(instances.length, 5);
      for (final inst in instances) {
        final wd = inst.scheduledDate!.weekday;
        expect([1, 3, 5], contains(wd));
      }
    });

    test('cria instâncias com every:N no intervalo correto', () async {
      // kToday = 2026-07-20. every:2 gera 22, 24, 26, 28, 30...
      final model = TaskItem()
        ..title = 'Correr'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'every:2'
        ..scheduledDate = kToday;
      await repo.create(model);

      await repo.ensureUpcomingInstances(
        daysAhead: 8,
        referenceDate: kToday,
      );

      final instances = await repo.getInstancesInRange(
        model.id,
        kToday,
        kToday.add(const Duration(days: 9)),
      );

      // kToday(modelo) + 22, 24, 26, 28 = 5 datas; modelo excluído → 4 instâncias
      expect(instances.length, 4);
    });

    test('getModelTasks retorna apenas tarefas com recurrenceRule', () async {
      // Cria uma tarefa com recorrência
      final model = TaskItem()
        ..title = 'Recorrente'
        ..type = TaskType.generic
        ..recurrenceRule = 'daily'
        ..scheduledDate = kToday;
      await repo.create(model);

      // Cria uma tarefa sem recorrência
      await repo.create(TaskItem()
        ..title = 'Avulsa'
        ..type = TaskType.generic
        ..scheduledDate = kToday);

      // Cria uma instância (não deve aparecer como modelo)
      final instance = TaskItem()
        ..title = 'Instância'
        ..type = TaskType.generic
        ..parentRecurringId = model.id
        ..scheduledDate = kToday;
      await repo.create(instance);

      final models = await repo.getModelTasks();
      expect(models.length, 1);
      expect(models[0].title, 'Recorrente');
    });

    test('modelo sem recurrenceRule não gera instâncias', () async {
      final model = TaskItem()
        ..title = 'Sem regra'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..scheduledDate = kToday;
      await repo.create(model);

      await repo.ensureUpcomingInstances(
        daysAhead: 5,
        referenceDate: kToday,
      );

      final instances = await repo.getInstancesInRange(
        model.id,
        kToday.subtract(const Duration(days: 1)),
        kToday.add(const Duration(days: 6)),
      );
      expect(instances, isEmpty);
    });

    test('instâncias recorrentes recebem cópia das subtarefas do modelo',
        () async {
      // Cria um modelo diário com 2 subtarefas
      final model = TaskItem()
        ..title = 'Treino'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'daily'
        ..scheduledDate = kToday;
      await repo.create(model);

      // Adiciona 2 subtarefas ao modelo
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = model.id
        ..title = 'Flexão'
        ..order = 0);
      await repo.addSubtask(SubTaskItem()
        ..parentTaskId = model.id
        ..title = 'Prancha'
        ..order = 1);

      // Gera instâncias
      await repo.ensureUpcomingInstances(
        daysAhead: 3,
        referenceDate: kToday,
      );

      // Verifica instâncias
      final instances = await repo.getInstancesInRange(
        model.id,
        kToday.subtract(const Duration(days: 1)),
        kToday.add(const Duration(days: 4)),
      );
      expect(instances.length, 3);

      // Cada instância deve ter sua própria cópia das 2 subtarefas
      for (final inst in instances) {
        final subtasks = await repo.getSubtasks(inst.id);
        expect(subtasks.length, 2,
            reason: 'Instância ${inst.id} deveria ter 2 subtarefas');

        // Verifica títulos e ordem
        expect(subtasks[0].title, 'Flexão');
        expect(subtasks[0].order, 0);
        expect(subtasks[0].isCompleted, false);
        expect(subtasks[1].title, 'Prancha');
        expect(subtasks[1].order, 1);
        expect(subtasks[1].isCompleted, false);

        // As subtarefas da instância são independentes (IDs diferentes)
        expect(subtasks[0].id, isNot(equals(subtasks[1].id)));
      }

      // Subtarefas do modelo continuam intactas
      final modelSubtasks = await repo.getSubtasks(model.id);
      expect(modelSubtasks.length, 2);
      expect(modelSubtasks[0].title, 'Flexão');
      expect(modelSubtasks[1].title, 'Prancha');
    });
  });
}

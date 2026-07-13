import 'package:flutter_test/flutter_test.dart';
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

  group('TaskRepository — ensureUpcomingInstances', () {
    test('cria instâncias diárias para os próximos 30 dias', () async {
      // Cria um modelo com recorrência diária
      final model = TaskItem()
        ..title = 'Meditar'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'daily'
        ..scheduledDate = DateTime.now();
      await repo.create(model);

      // Gera instâncias
      await repo.ensureUpcomingInstances(daysAhead: 30);

      // Verifica que foram criadas instâncias para cada dia (hoje + 30)
      final instances = await repo.getInstancesInRange(
        model.id,
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 31)),
      );
      expect(instances.length, 31); // hoje + 30 dias

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
        ..scheduledDate = DateTime.now();
      await repo.create(model);

      // Primeira geração
      await repo.ensureUpcomingInstances(daysAhead: 5);
      final firstGen = await repo.getInstancesInRange(
        model.id,
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 6)),
      );
      expect(firstGen.length, 6); // hoje + 5

      // Segunda geração (mesmo período)
      await repo.ensureUpcomingInstances(daysAhead: 5);
      final secondGen = await repo.getInstancesInRange(
        model.id,
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 6)),
      );
      expect(secondGen.length, 6); // ainda 6, sem duplicatas
    });

    test('cria instâncias semanais nos dias corretos', () async {
      // Segunda(1), Quarta(3), Sexta(5)
      final model = TaskItem()
        ..title = 'Estudar'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'weekly:MO,WE,FR'
        ..scheduledDate = DateTime(2026, 7, 13); // Monday
      await repo.create(model);

      // Gera instâncias para 2 semanas
      await repo.ensureUpcomingInstances(daysAhead: 13);

      final instances = await repo.getInstancesInRange(
        model.id,
        DateTime(2026, 7, 13),
        DateTime(2026, 7, 26),
      );

      // 13 Jul (Mon) + 15 Jul (Wed) + 17 Jul (Fri) + 20 Jul (Mon) + 22 Jul (Wed) + 24 Jul (Fri) = 6
      expect(instances.length, 6);
      for (final inst in instances) {
        final wd = inst.scheduledDate!.weekday;
        expect([1, 3, 5], contains(wd));
      }
    });

    test('cria instâncias com every:N no intervalo correto', () async {
      final model = TaskItem()
        ..title = 'Correr'
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..recurrenceRule = 'every:2'
        ..scheduledDate = DateTime(2026, 7, 13); // Monday
      await repo.create(model);

      await repo.ensureUpcomingInstances(daysAhead: 8);

      final instances = await repo.getInstancesInRange(
        model.id,
        DateTime(2026, 7, 13),
        DateTime(2026, 7, 21),
      );

      // 13, 15, 17, 19, 21 = 5 instâncias
      expect(instances.length, 5);
    });

    test('getModelTasks retorna apenas tarefas com recurrenceRule', () async {
      // Cria uma tarefa com recorrência
      final model = TaskItem()
        ..title = 'Recorrente'
        ..type = TaskType.generic
        ..recurrenceRule = 'daily'
        ..scheduledDate = DateTime.now();
      await repo.create(model);

      // Cria uma tarefa sem recorrência
      await repo.create(TaskItem()
        ..title = 'Avulsa'
        ..type = TaskType.generic
        ..scheduledDate = DateTime.now());

      // Cria uma instância (não deve aparecer como modelo)
      final instance = TaskItem()
        ..title = 'Instância'
        ..type = TaskType.generic
        ..parentRecurringId = model.id
        ..scheduledDate = DateTime.now();
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
        ..scheduledDate = DateTime.now();
      await repo.create(model);

      await repo.ensureUpcomingInstances(daysAhead: 5);

      final instances = await repo.getInstancesInRange(
        model.id,
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 6)),
      );
      expect(instances, isEmpty);
    });
  });
}

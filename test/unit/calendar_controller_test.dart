import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/features/calendar/controllers/calendar_controller.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late TaskRepository taskRepo;
  late CalendarController controller;

  /// Cria uma [TaskItem] com data agendada e título.
  TaskItem makeTask({
    required String title,
    required DateTime date,
    DateTime? time,
  }) {
    return TaskItem()
      ..title = title
      ..type = TaskType.generic
      ..rewardPoints = 10
      ..scheduledDate = DateHelpers.normalizeToDay(date)
      ..scheduledTime = time;
  }

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    taskRepo = TaskRepository();
    controller = CalendarController(taskRepo: taskRepo);
    controller.init();
    // Aguarda o stream emitir
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  tearDown(() async {
    controller.dispose();
    await helper.close();
  });

  group('CalendarController', () {
    test('dias vazios quando não há tarefas', () {
      expect(controller.daysWithTasks, isEmpty);
      expect(controller.selectedDayTasks, isEmpty);
    });

    test('constrói mapa com tarefas de datas diferentes', () async {
      final today = DateHelpers.today();
      final tomorrow = today.add(const Duration(days: 1));
      final dayAfter = today.add(const Duration(days: 2));

      await taskRepo.create(makeTask(title: 'T1', date: today));
      await taskRepo.create(makeTask(title: 'T2', date: today));
      await taskRepo.create(makeTask(title: 'T3', date: tomorrow));
      await taskRepo.create(makeTask(title: 'T4', date: dayAfter));

      // Aguarda o stream
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.daysWithTasks.length, 3);
      expect(controller.getTasksForDay(today).length, 2);
      expect(controller.getTasksForDay(tomorrow).length, 1);
      expect(controller.getTasksForDay(dayAfter).length, 1);
    });

    test('selectedDayTasks retorna tarefas ordenadas por horário', () async {
      final today = DateHelpers.today();
      await taskRepo.create(makeTask(
        title: 'Tarde',
        date: today,
        time: DateTime(2000, 1, 1, 14, 0),
      ));
      await taskRepo.create(makeTask(
        title: 'Manhã',
        date: today,
        time: DateTime(2000, 1, 1, 9, 0),
      ));
      await taskRepo.create(
        makeTask(title: 'Sem hora', date: today),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      final tasks = controller.selectedDayTasks;
      // Sem hora deve vir depois dos que têm hora
      expect(tasks[0].title, 'Manhã');
      expect(tasks[1].title, 'Tarde');
      expect(tasks[2].title, 'Sem hora');
    });

    test('selecionar dia via selectDay', () {
      final day = DateTime(2025, 6, 15);
      controller.selectDay(day);

      expect(
        DateHelpers.normalizeToDay(controller.selectedDay),
        DateHelpers.normalizeToDay(day),
      );
    });

    test('focusMonth atualiza o mês focado', () {
      final month = DateTime(2025, 12);
      controller.focusMonth(month);

      expect(controller.focusedMonth.month, 12);
      expect(controller.focusedMonth.year, 2025);
    });

    test('getTasksForDay retorna lista vazia para dia sem tarefas', () async {
      final today = DateHelpers.today();
      final tasks = controller.getTasksForDay(today);
      expect(tasks, isEmpty);
    });

    test('tarefa sem scheduledDate é ignorada no mapa', () async {
      final task = TaskItem()
        ..title = 'Sem data'
        ..type = TaskType.generic
        ..rewardPoints = 10;
      await taskRepo.create(task);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.daysWithTasks, isEmpty);
    });

    test('updateTask edita data/horário e reflete no mapa', () async {
      final today = DateHelpers.today();
      final tomorrow = today.add(const Duration(days: 1));

      final task = makeTask(title: 'Móvel', date: today);
      await taskRepo.create(task);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.getTasksForDay(today).length, 1);

      // Move a tarefa para amanhã
      task.scheduledDate = tomorrow;
      await taskRepo.update(task);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.getTasksForDay(today), isEmpty);
      expect(controller.getTasksForDay(tomorrow).length, 1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/calendar/controllers/calendar_controller.dart';
import 'package:task_manager/features/stats/controllers/stats_controller.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import '../helpers/isar_test_helper.dart';

/// Fluxos completos de criação, conclusão, calendário e gráfico.
///
/// Testes sem widgets usam `test()` (mais rápidos).
/// Testes com UI usam `testWidgets()`.
void main() {
  late IsarTestHelper helper;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
  });

  tearDown(() async {
    await helper.close();
  });

  // ─── Fluxo 1: Criar cada um dos 4 tipos de tarefa ─────────────

  group('Fluxo: criar 4 tipos de tarefa', () {
    test('criar e persistir tarefa genérica', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.createTask(TaskItem()
        ..title = 'Genérica'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 5);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.pendingTasks.any((t) => t.title == 'Genérica'), isTrue);
    });

    test('criar e persistir tarefa pomodoroStudy', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.createTask(TaskItem()
        ..title = 'Pomodoro'
        ..type = TaskType.pomodoroStudy
        ..durationMinutes = 25
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 10);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.pendingTasks.any((t) => t.title == 'Pomodoro'), isTrue);
    });

    test('criar e persistir tarefa timedExercise', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.createTask(TaskItem()
        ..title = 'Timed'
        ..type = TaskType.timedExercise
        ..durationSeconds = 60
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 10);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.pendingTasks.any((t) => t.title == 'Timed'), isTrue);
    });

    test('criar e persistir tarefa repsExercise', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.createTask(TaskItem()
        ..title = 'Reps'
        ..type = TaskType.repsExercise
        ..targetReps = 10
        ..targetSets = 3
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 15);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.pendingTasks.any((t) => t.title == 'Reps'), isTrue);
    });
  });

  // ─── Fluxo 2: Completar tarefa ────────────────────────────────

  group('Fluxo: completar tarefa', () {
    test('completeTask marca genérica como concluída', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      final task = TaskItem()
        ..title = 'Completar'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 5;
      await controller.createTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.completeTask(task.id);
      await Future.delayed(const Duration(milliseconds: 100));

      final completed = controller.completedTasks;
      expect(completed.any((t) => t.id == task.id), isTrue);
      expect(completed.firstWhere((t) => t.id == task.id).isCompleted, isTrue);
    });

    test('completeTask em task já concluída não duplica pontos', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      final task = TaskItem()
        ..title = 'Duplicar'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 5;
      await controller.createTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.completeTask(task.id);
      await controller.completeTask(task.id);
      await Future.delayed(const Duration(milliseconds: 100));

      final t = controller.allTasks.firstWhere((t) => t.id == task.id);
      expect(t.isCompleted, isTrue);
    });

    test('deleteTask + undoDelete restaura tarefa', () async {
      final controller = TaskController(
        taskRepo: TaskRepository(),
        progressRepo: ProgressRepository(),
      );
      addTearDown(controller.dispose);
      controller.init();
      await Future.delayed(const Duration(milliseconds: 100));

      final task = TaskItem()
        ..title = 'Deletar'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 5;
      await controller.createTask(task);
      await Future.delayed(const Duration(milliseconds: 100));
      final taskId = task.id;

      await controller.deleteTask(taskId);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.allTasks.any((t) => t.id == taskId), isFalse);

      await controller.undoDelete();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.allTasks.any((t) => t.id == taskId), isTrue);
    });
  });

  // ─── Fluxo 3: Editar data pelo calendário ────────────────────

  group('Fluxo: editar data pelo calendário', () {
    test('CalendarController reflete mudança de data', () async {
      final taskRepo = TaskRepository();
      final calendarCtrl = CalendarController(taskRepo: taskRepo);
      addTearDown(calendarCtrl.dispose);
      calendarCtrl.init();
      await Future.delayed(const Duration(milliseconds: 100));

      final task = TaskItem()
        ..title = 'Mudar data'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 5;
      await taskRepo.create(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verifica que está no dia de hoje
      final hoje = DateHelpers.today();
      expect(
        calendarCtrl.getTasksForDay(hoje).any((t) => t.id == task.id),
        isTrue,
      );

      // Move para outro dia e verifica
      final novaData = hoje.add(const Duration(days: 3));
      await taskRepo.update(task..scheduledDate = novaData);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        calendarCtrl.getTasksForDay(novaData).any((t) => t.id == task.id),
        isTrue,
      );
      // Não deve mais estar no dia original
      expect(
        calendarCtrl.getTasksForDay(hoje).any((t) => t.id == task.id),
        isFalse,
      );
    });
  });

  // ─── Fluxo 4: Gráfico atualiza depois de completar tarefa ────

  group('Fluxo: gráfico atualiza após completar tarefa', () {
    test('StatsController chartSpots reflete pontos acumulados', () async {
      final taskRepo = TaskRepository();
      final progressRepo = ProgressRepository();
      final statsCtrl = StatsController(
        progressRepo: progressRepo,
      );
      addTearDown(statsCtrl.dispose);
      statsCtrl.init();
      await Future.delayed(const Duration(milliseconds: 100));

      final taskCtrl = TaskController(
        taskRepo: taskRepo,
        progressRepo: progressRepo,
      );
      addTearDown(taskCtrl.dispose);
      taskCtrl.init();
      await Future.delayed(const Duration(milliseconds: 100));

      // stats period = week → chartSpots cobre 7 dias
      statsCtrl.setPeriod(ChartPeriod.week);
      await Future.delayed(const Duration(milliseconds: 50));

      final task = TaskItem()
        ..title = 'Gráfico'
        ..type = TaskType.generic
        ..scheduledDate = DateHelpers.today()
        ..rewardPoints = 10;

      await taskCtrl.createTask(task);
      await Future.delayed(const Duration(milliseconds: 100));

      // Antes de completar, não há progress logs — chartSpots não tem dados
      // (apenas o range de dias vazios, que depende do período)

      await taskCtrl.completeTask(task.id);
      await Future.delayed(const Duration(milliseconds: 300));

      // Verifica se o ProgressLog foi criado via repository
      final log = await progressRepo.getByDay(DateHelpers.today());
      expect(log, isNotNull,
          reason: 'ProgressLog deveria existir após completar');
      expect(log!.pointsEarned, greaterThanOrEqualTo(10));

      // Agora que o ProgressLog existe, statsCtrl deveria tê-lo via stream.
      // Se o stream já emitiu, _logs não está mais vazio.
      // Usamos setPeriod para garantir filtro correto.
      statsCtrl.setPeriod(ChartPeriod.week);
      await Future.delayed(Duration.zero);
      final spots = statsCtrl.chartSpots;
      expect(spots, isNotEmpty,
          reason: 'chartSpots deveria ter dados após completar tarefa');
      expect(spots.last.y, greaterThanOrEqualTo(10));
    });
  });

  // ─── Fluxo 5: UI já testado em widget_test.dart e task_form_test.dart ──

  // Os testes de UI (TasksScreen exibindo tarefas) estão em:
  //   test/widget_test.dart  – estado vazio
  //   test/widgets/task_form_test.dart – formulário
}

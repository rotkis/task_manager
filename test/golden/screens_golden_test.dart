// Testes golden (regressão visual).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/features/calendar/controllers/calendar_controller.dart';
import 'package:task_manager/features/calendar/screens/calendar_screen.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/tasks/screens/tasks_screen.dart';
import 'package:task_manager/theme/app_theme.dart';
import '../helpers/isar_test_helper.dart';

/// Testes de regressão visual (golden) das telas principais.
///
/// Gere/atualize as imagens de referência com:
///   flutter test --update-goldens --tags golden
///
/// Depois, execute para comparar:
///   flutter test --tags golden
void main() {
  late IsarTestHelper isarHelper;

  setUp(() async {
    isarHelper = IsarTestHelper();
    await isarHelper.open();
    await initializeDateFormatting('pt_BR');
  });

  tearDown(() async {
    await isarHelper.close();
  });

  group('Golden — TasksScreen', () {
    testWidgets('vazia — tema light', (tester) async {
      final controller = TaskController();
      addTearDown(controller.dispose);
      // Não chama init() — sem stream. Dados padrão = lista vazia.

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskController>.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: TasksScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/tasks_screen_empty_light.png'),
      );
    });

    testWidgets('vazia — tema dark', (tester) async {
      final controller = TaskController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskController>.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: TasksScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/tasks_screen_empty_dark.png'),
      );
    });

    testWidgets('com tarefa pendente — tema light', (tester) async {
      final controller = TaskController();
      addTearDown(controller.dispose);
      // Injeta uma tarefa diretamente, sem stream do Isar
      controller.setTodayTasksDirectly([
        TaskItem()
          ..title = 'Estudar Matemática'
          ..type = TaskType.generic
          ..rewardPoints = 10,
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskController>.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: TasksScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/tasks_screen_with_task_light.png'),
      );
    });

    testWidgets('com tarefa pendente — tema dark', (tester) async {
      final controller = TaskController();
      addTearDown(controller.dispose);
      controller.setTodayTasksDirectly([
        TaskItem()
          ..title = 'Estudar Matemática'
          ..type = TaskType.generic
          ..rewardPoints = 10,
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<TaskController>.value(
          value: controller,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(body: TasksScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/tasks_screen_with_task_dark.png'),
      );
    });
  });

  group('Golden — CalendarScreen markers', () {
    final today = DateTime.now();

    /// Cria uma tarefa no dia de hoje com o estado e título dados.
    TaskItem task({
      int id = 1,
      String title = 'Tarefa',
      bool completed = false,
    }) {
      return TaskItem()
        ..id = id
        ..title = title
        ..type = TaskType.generic
        ..rewardPoints = 10
        ..scheduledDate = today
        ..isCompleted = completed;
    }

    /// Constrói o widget de teste injetando o [CalendarController] via
    /// parâmetro do construtor (não via Provider).
    Widget buildApp({
      required CalendarController controller,
      required ThemeData theme,
    }) {
      // TaskController via Provider é necessário pelo CalendarScreen
      final taskCtrl = TaskController();
      addTearDown(taskCtrl.dispose);

      return ChangeNotifierProvider<TaskController>.value(
        value: taskCtrl,
        child: MaterialApp(
          theme: theme,
          home: Scaffold(
            body: CalendarScreen(controller: controller),
          ),
        ),
      );
    }

    /// Constrói o widget e devolve o [CalendarController] para configurar
    /// os dados antes do primeiro frame.
    Future<CalendarController> buildControllerAndPump(
      WidgetTester tester, {
      required List<TaskItem> tasks,
      required ThemeData theme,
    }) async {
      final controller = CalendarController();
      controller.setTasksDirectly(tasks);
      await tester.pumpWidget(buildApp(
        controller: controller,
        theme: theme,
      ));
      await tester.pump(const Duration(milliseconds: 200));
      return controller;
    }

    testWidgets('dia sem tarefa — tema light', (tester) async {
      await buildControllerAndPump(tester, tasks: [], theme: AppTheme.light);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/calendar_empty_light.png'),
      );
    });

    testWidgets('dia com 1 tarefa pendente — tema light', (tester) async {
      await buildControllerAndPump(
        tester,
        tasks: [
          task(id: 1, title: 'Estudar Matemática', completed: false),
        ],
        theme: AppTheme.light,
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/calendar_1_pending_light.png'),
      );
    });

    testWidgets('dia com tarefas concluídas — tema light', (tester) async {
      await buildControllerAndPump(
        tester,
        tasks: [
          task(id: 1, title: 'Estudar', completed: true),
          task(id: 2, title: 'Exercício', completed: true),
        ],
        theme: AppTheme.light,
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/calendar_all_completed_light.png'),
      );
    });

    testWidgets('dia com mais de 3 tarefas — tema dark', (tester) async {
      await buildControllerAndPump(
        tester,
        tasks: [
          task(id: 1, title: 'Tarefa A', completed: false),
          task(id: 2, title: 'Tarefa B', completed: true),
          task(id: 3, title: 'Tarefa C', completed: false),
          task(id: 4, title: 'Tarefa D', completed: false),
        ],
        theme: AppTheme.dark,
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/calendar_4_tasks_dark.png'),
      );
    });
  });
}

// Testes golden (regressão visual).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/tasks/screens/tasks_screen.dart';
import 'package:task_manager/theme/app_theme.dart';

/// Testes de regressão visual (golden) das telas principais.
///
/// IMPORTANTE: estes testes NÃO usam Isar/streams. Em vez de chamar
/// controller.init() (que ativaria streams do Isar e causaria race
/// condition no tearDown do testWidgets), usam o método
/// [TaskController.setTodayTasksDirectly] para injetar dados
/// estaticamente.
///
/// Gere/atualize as imagens de referência com:
///   flutter test --update-goldens --tags golden
///
/// Depois, execute para comparar:
///   flutter test --tags golden
void main() {
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
}

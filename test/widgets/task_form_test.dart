import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/tasks/widgets/task_form.dart';
import '../helpers/isar_test_helper.dart';

/// Cria o app wrapper para teste, injetando o controller.
/// TaskForm é colocado como rota para que Navigator.pop funcione.
Widget _buildTestApp(TaskController controller, {TaskItem? task}) {
  return MaterialApp(
    home: ChangeNotifierProvider<TaskController>.value(
      value: controller,
      child: Builder(
        builder: (context) => Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => TaskForm(task: task),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  late IsarTestHelper helper;
  late TaskController controller;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    controller = TaskController(
      taskRepo: TaskRepository(),
      progressRepo: ProgressRepository(),
    );
  });

  tearDown(() async {
    controller.dispose();
    await helper.close();
  });

  group('TaskForm — widget', () {
    testWidgets('valida título obrigatório', (tester) async {
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('exibe campo de duração quando tarefa é do tipo Pomodoro',
        (tester) async {
      final task = TaskItem()
        ..title = 'Estudo'
        ..type = TaskType.pomodoroStudy
        ..durationMinutes = 25;

      await tester.pumpWidget(_buildTestApp(controller, task: task));
      await tester.pumpAndSettle();

      expect(find.text('Duração do foco (minutos)'), findsOneWidget);
    });

    testWidgets('exibe campo de repetições quando tarefa é repsExercise',
        (tester) async {
      final task = TaskItem()
        ..title = 'Flexões'
        ..type = TaskType.repsExercise
        ..targetReps = 10;

      await tester.pumpWidget(_buildTestApp(controller, task: task));
      await tester.pumpAndSettle();

      expect(find.text('Meta de repetições'), findsOneWidget);
    });

    testWidgets('não exibe campos específicos para tarefa genérica',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(controller));
      await tester.pumpAndSettle();

      expect(find.text('Duração do foco (minutos)'), findsNothing);
      expect(find.text('Meta de repetições'), findsNothing);
    });
  });
}

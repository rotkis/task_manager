import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/tasks/screens/tasks_screen.dart';
import 'helpers/isar_test_helper.dart';

Widget _buildTestApp() {
  return ChangeNotifierProvider<TaskController>(
    create: (_) => TaskController(
      taskRepo: TaskRepository(),
      progressRepo: ProgressRepository(),
    ),
    child: const MaterialApp(
      home: Scaffold(body: TasksScreen()),
    ),
  );
}

void main() {
  late IsarTestHelper helper;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
  });

  tearDown(() async {
    await helper.close();
  });

  testWidgets('TasksScreen mostra estado vazio quando não há tarefas',
      (tester) async {
    await tester.pumpWidget(_buildTestApp());
    // pump em vez de pumpAndSettle para evitar loops infinitos com streams
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Nenhuma tarefa para hoje'), findsOneWidget);
  });
}

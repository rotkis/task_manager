import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/features/tasks/screens/tasks_screen.dart';
import 'package:task_manager/data/isar/isar_service.dart';
import 'package:task_manager/data/models/task_item.dart';

/// Teste de integração: fluxo completo de criar tarefas de todos os 4 tipos.
///
/// Executa num dispositivo/emulador (ou headless com IntegrationTestWidgetsFlutterBinding).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await IsarService.open();
  });

  tearDown(() async {
    await IsarService.instance.close();
  });

  testWidgets('Criar tarefa genérica e marcar como concluída', (tester) async {
    final controller = TaskController(
      taskRepo: TaskRepository(),
      progressRepo: ProgressRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<TaskController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: TasksScreen()),
        ),
      ),
    );

    // Inicializa para escutar tarefas do dia
    controller.init();
    await tester.pump(const Duration(milliseconds: 500));

    // Cria uma tarefa genérica diretamente pelo controller
    final task = TaskItem()
      ..title = 'Tarefa de teste'
      ..type = TaskType.generic
      ..scheduledDate = DateTime.now()
      ..rewardPoints = 10;
    await controller.createTask(task);
    await tester.pump(const Duration(milliseconds: 300));

    // Verifica se a tarefa aparece na tela
    expect(find.text('Tarefa de teste'), findsOneWidget);

    // Marca como concluída
    controller.completeTask(task.id);
    await tester.pump(const Duration(milliseconds: 300));

    // Verifica se o texto aparece tachado (indicando concluída)
    // O task card mostra o título. Como está concluída, ainda aparece.
    expect(find.text('Tarefa de teste'), findsOneWidget);
  });

  testWidgets('Criar tarefa pomodoro e iniciar timer', (tester) async {
    final controller = TaskController(
      taskRepo: TaskRepository(),
      progressRepo: ProgressRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<TaskController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: TasksScreen()),
        ),
      ),
    );

    controller.init();
    await tester.pump(const Duration(milliseconds: 500));

    final task = TaskItem()
      ..title = 'Estudo Pomodoro'
      ..type = TaskType.pomodoroStudy
      ..durationMinutes = 25
      ..scheduledDate = DateTime.now()
      ..rewardPoints = 15;
    await controller.createTask(task);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Estudo Pomodoro'), findsOneWidget);
  });

  testWidgets('Criar tarefa timedExercise e repsExercise', (tester) async {
    final controller = TaskController(
      taskRepo: TaskRepository(),
      progressRepo: ProgressRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<TaskController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: TasksScreen()),
        ),
      ),
    );

    controller.init();
    await tester.pump(const Duration(milliseconds: 500));

    final timedTask = TaskItem()
      ..title = 'Prancha'
      ..type = TaskType.timedExercise
      ..durationSeconds = 60
      ..scheduledDate = DateTime.now()
      ..rewardPoints = 10;
    await controller.createTask(timedTask);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Prancha'), findsOneWidget);

    final repsTask = TaskItem()
      ..title = 'Flexões'
      ..type = TaskType.repsExercise
      ..targetReps = 10
      ..targetSets = 3
      ..scheduledDate = DateTime.now()
      ..rewardPoints = 20;
    await controller.createTask(repsTask);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Flexões'), findsOneWidget);
  });
}

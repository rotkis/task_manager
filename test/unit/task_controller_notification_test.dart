import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import 'package:task_manager/features/notifications/alarm_service.dart';
import 'package:task_manager/features/notifications/notification_service.dart';
import 'package:task_manager/features/tasks/controllers/task_controller.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import '../helpers/isar_test_helper.dart';

// ─── Test spies ─────────────────────────────────────────────────────────────

/// Spy que registra chamadas ao [NotificationService] sem usar plugins reais.
class NotificationServiceSpy extends NotificationService {
  final List<String> calls = [];
  int? lastCancelledId;
  TaskItem? lastScheduled;

  @override
  Future<void> init() async {
    // no-op em testes
  }

  @override
  Future<void> schedule(TaskItem task) async {
    calls.add('schedule');
    lastScheduled = task;
    task.notificationId = task.id;
  }

  @override
  Future<void> cancel(int notificationId) async {
    calls.add('cancel');
    lastCancelledId = notificationId;
  }

  @override
  Future<void> cancelSeries(TaskItem task) async {
    calls.add('cancelSeries');
    // A implementação real chamaria cancel() para cada ID da série.
    // O spy apenas registra e guarda o primeiro ID como referência.
    final ids = NotificationService.notificationIdsForTask(task);
    if (ids.isNotEmpty) lastCancelledId = ids.first;
  }
}

/// Spy que registra chamadas ao [AlarmService] sem usar plugins reais.
class AlarmServiceSpy extends AlarmService {
  final List<String> calls = [];
  int? lastCancelledId;
  TaskItem? lastScheduled;

  @override
  Future<void> init() async {
    // no-op em testes
  }

  @override
  Future<void> schedule(TaskItem task) async {
    calls.add('schedule');
    lastScheduled = task;
    task.alarmId = task.id;
  }

  @override
  Future<void> cancel(int alarmId) async {
    calls.add('cancel');
    lastCancelledId = alarmId;
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Cria uma [TaskItem] com horário agendado (necessário para notificação).
TaskItem _taskWithSchedule({
  String title = 'Tarefa teste',
  int points = 10,
  bool isImportant = false,
  DateTime? scheduledDate,
  DateTime? scheduledTime,
}) {
  return TaskItem()
    ..title = title
    ..type = TaskType.generic
    ..rewardPoints = points
    ..isImportant = isImportant
    ..scheduledDate = scheduledDate ?? DateHelpers.today()
    ..scheduledTime =
        scheduledTime ?? DateTime(2025, 1, 1, 10, 0); // só a hora importa
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late IsarTestHelper helper;
  late TaskRepository taskRepo;
  late ProgressRepository progressRepo;
  late NotificationServiceSpy notificationSpy;
  late AlarmServiceSpy alarmSpy;
  late TaskController controller;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    taskRepo = TaskRepository();
    progressRepo = ProgressRepository();
    notificationSpy = NotificationServiceSpy();
    alarmSpy = AlarmServiceSpy();
    controller = TaskController(
      taskRepo: taskRepo,
      progressRepo: progressRepo,
      notificationService: notificationSpy,
      alarmService: alarmSpy,
    );
  });

  tearDown(() async {
    controller.dispose();
    await helper.close();
  });

  group('TaskController — notificações e alarmes', () {
    test('createTask agenda notificação para tarefa normal com horário',
        () async {
      final task = _taskWithSchedule(isImportant: false);

      await controller.createTask(task);

      expect(notificationSpy.calls, contains('schedule'));
      expect(alarmSpy.calls, isEmpty);
      expect(notificationSpy.lastScheduled?.id, greaterThan(0));
      expect(task.notificationId, task.id);
    });

    test('createTask agenda alarme para tarefa importante com horário',
        () async {
      final task = _taskWithSchedule(isImportant: true);

      await controller.createTask(task);

      expect(alarmSpy.calls, contains('schedule'));
      expect(notificationSpy.calls, isEmpty);
      expect(alarmSpy.lastScheduled?.id, greaterThan(0));
      expect(task.alarmId, task.id);
    });

    test('createTask não agenda notificação se tarefa não tem horário',
        () async {
      final task = _taskWithSchedule()
        ..scheduledDate = null
        ..scheduledTime = null;

      await controller.createTask(task);

      expect(notificationSpy.calls, isEmpty);
      expect(alarmSpy.calls, isEmpty);
    });

    test('updateTask cancela notificação antiga e agenda nova', () async {
      final task = _taskWithSchedule(isImportant: false);
      await controller.createTask(task);

      // Limpa registros após create
      notificationSpy.calls.clear();
      alarmSpy.calls.clear();

      // Atualiza o título
      task.title = 'Título editado';
      await controller.updateTask(task);

      // Deve ter cancelado a antiga e agendado a nova
      expect(notificationSpy.calls, ['cancelSeries', 'schedule']);
      expect(notificationSpy.lastCancelledId, task.id);
      expect(notificationSpy.lastScheduled?.id, task.id);
    });

    test('updateTask cancela alarme antigo e agenda novo para importante',
        () async {
      final task = _taskWithSchedule(isImportant: true);
      await controller.createTask(task);

      alarmSpy.calls.clear();
      notificationSpy.calls.clear();

      task.title = 'Importante editado';
      await controller.updateTask(task);

      expect(alarmSpy.calls, ['cancel', 'schedule']);
      expect(alarmSpy.lastCancelledId, task.id);
      expect(alarmSpy.lastScheduled?.id, task.id);
    });

    test('deleteTask cancela notificação antes de remover', () async {
      final task = _taskWithSchedule(isImportant: false);
      await controller.createTask(task);

      notificationSpy.calls.clear();

      await controller.deleteTask(task.id);

      expect(notificationSpy.calls, contains('cancelSeries'));
      // Verifica que a tarefa foi removida
      final deleted = await taskRepo.getById(task.id);
      expect(deleted, isNull);
    });

    test('deleteTask cancela alarme antes de remover para importante',
        () async {
      final task = _taskWithSchedule(isImportant: true);
      await controller.createTask(task);

      alarmSpy.calls.clear();

      await controller.deleteTask(task.id);

      expect(alarmSpy.calls, contains('cancel'));
    });

    test('completeTask cancela notificação', () async {
      final task = _taskWithSchedule(isImportant: false);
      await controller.createTask(task);

      notificationSpy.calls.clear();

      await controller.completeTask(task.id);

      expect(notificationSpy.calls, contains('cancelSeries'));
    });

    test('completeTask cancela alarme para tarefa importante', () async {
      final task = _taskWithSchedule(isImportant: true);
      await controller.createTask(task);

      alarmSpy.calls.clear();

      await controller.completeTask(task.id);

      expect(alarmSpy.calls, contains('cancel'));
    });

    test('undoDelete restaura tarefa e re-agenda notificação', () async {
      final task = _taskWithSchedule(isImportant: false);
      await controller.createTask(task);

      notificationSpy.calls.clear();

      await controller.deleteTask(task.id);
      await controller.undoDelete();

      // undoDelete re-cria a tarefa e re-agenda (notificação)
      expect(notificationSpy.calls.last, 'schedule');
      expect(notificationSpy.lastScheduled, isNotNull);
      // A tarefa foi restaurada no banco
      final all = await taskRepo.watchAll().first;
      expect(all.length, 1);
    });

    test('updateTask sem horário não agenda nem cancela', () async {
      final task = _taskWithSchedule(isImportant: false);
      // Cria sem horário
      task.scheduledDate = null;
      task.scheduledTime = null;
      await controller.createTask(task);

      notificationSpy.calls.clear();

      // Atualiza mas ainda sem horário
      task.title = 'Ainda sem horário';
      await controller.updateTask(task);

      expect(notificationSpy.calls, isEmpty);
    });
  });
}

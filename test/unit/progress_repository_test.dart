import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/isar/isar_service.dart';
import 'package:task_manager/core/utils/date_helpers.dart';
import 'package:task_manager/data/models/progress_log.dart';
import 'package:task_manager/data/repositories/progress_repository.dart';
import '../helpers/isar_test_helper.dart';

void main() {
  late IsarTestHelper helper;
  late ProgressRepository repo;

  setUp(() async {
    helper = IsarTestHelper();
    await helper.open();
    repo = ProgressRepository();
  });

  tearDown(() async {
    await helper.close();
  });

  group('ProgressRepository — streak', () {
    test('primeiro dia: currentStreak = 1', () async {
      // Não há log do dia anterior — ao incrementar hoje, streak deve ser 1.
      await repo.incrementToday(10);

      final today = DateHelpers.today();
      final log = await repo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.currentStreak, 1);
      expect(log.tasksCompleted, 1);
      expect(log.pointsEarned, 10);
    });

    test('dia seguido: currentStreak incrementa', () async {
      final today = DateHelpers.today();
      final yesterday = DateHelpers.yesterday();

      // Cria manualmente o log de ontem com streak = 1
      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.progressLogs.putByDay(ProgressLog()
          ..day = yesterday
          ..tasksCompleted = 1
          ..pointsEarned = 5
          ..currentStreak = 1);
      });

      // Hoje completa tarefa → streak deve ser 2
      await repo.incrementToday(10);

      final log = await repo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.currentStreak, 2);
      expect(log.tasksCompleted, 1);
    });

    test('quebrou streak: reseta para 1', () async {
      final today = DateHelpers.today();
      final yesterday = DateHelpers.yesterday();

      // Cria log de ontem com tasksCompleted = 0 (nenhuma tarefa concluída)
      // Isso significa que a streak quebrou.
      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.progressLogs.putByDay(ProgressLog()
          ..day = yesterday
          ..tasksCompleted = 0
          ..pointsEarned = 0
          ..currentStreak = 3); // streak antiga
      });

      // Hoje completa tarefa → streak deve resetar para 1
      await repo.incrementToday(10);

      final log = await repo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.currentStreak, 1);
      expect(log.tasksCompleted, 1);
    });

    test('dois dias seguidos acumulam streak', () async {
      final today = DateHelpers.today();
      final yesterday = DateHelpers.yesterday();

      // Cria log de ontem com streak = 2
      final isar = IsarService.instance;
      await isar.writeTxn(() async {
        await isar.progressLogs.putByDay(ProgressLog()
          ..day = yesterday
          ..tasksCompleted = 1
          ..pointsEarned = 5
          ..currentStreak = 2);
      });

      // Hoje completa tarefa → streak deve ser 3
      await repo.incrementToday(10);

      final log = await repo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.currentStreak, 3);
    });

    test('incrementToday soma pontos e tarefas cumulativamente', () async {
      await repo.incrementToday(10);
      await repo.incrementToday(5);

      final today = DateHelpers.today();
      final log = await repo.getByDay(today);
      expect(log, isNotNull);
      expect(log!.tasksCompleted, 2);
      expect(log.pointsEarned, 15);
    });
  });
}

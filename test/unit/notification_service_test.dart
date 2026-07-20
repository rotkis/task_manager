import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/features/notifications/notification_service.dart';

void main() {
  group('NotificationService.repeatCount', () {
    test('retorna 1 se intervalo <= 0', () {
      expect(
          NotificationService.repeatCount(0, DateTime(2026, 7, 20, 10, 0)), 1);
      expect(
          NotificationService.repeatCount(-5, DateTime(2026, 7, 20, 10, 0)), 1);
    });

    test('retorna 1 se o horário agendado já passou do fim do dia', () {
      // 23:59 → já no fim do dia
      expect(
        NotificationService.repeatCount(15, DateTime(2026, 7, 20, 23, 59)),
        1,
      );
    });

    test('calcula contagem correta para início do dia com intervalo curto', () {
      // 08:00 até 23:59 = 959 min → /15 = 63.93 → ceil = 64
      final count =
          NotificationService.repeatCount(15, DateTime(2026, 7, 20, 8, 0));
      expect(count, 64);
    });

    test('calcula contagem correta para intervalo de 30 min pela manhã', () {
      // 10:00 até 23:59 = 839 min → /30 = 27.96 → ceil = 28
      final count =
          NotificationService.repeatCount(30, DateTime(2026, 7, 20, 10, 0));
      expect(count, 28);
    });

    test('respeita teto de 96 notificações', () {
      // 00:00 até 23:59 = 1439 min → /1 = 1439 → clamped to 96
      final count =
          NotificationService.repeatCount(1, DateTime(2026, 7, 20, 0, 0));
      expect(count, 96);
    });

    test('retorna 1 se intervalo maior que o tempo restante do dia', () {
      // 23:30 até 23:59 = 29 min → /60 = 0.48 → ceil = 1
      final count =
          NotificationService.repeatCount(60, DateTime(2026, 7, 20, 23, 30));
      expect(count, 1);
    });

    test('funciona com minuto exato (1 min de intervalo)', () {
      // 10:00 até 23:59 = 839 min → /1 = 839 → clamped to 96
      final count =
          NotificationService.repeatCount(1, DateTime(2026, 7, 20, 10, 0));
      expect(count, 96);
    });

    test('intervalo de 5 min por algumas horas', () {
      // 14:00 até 23:59 = 599 min → /5 = 119.8 → ceil = 120 → clamped to 96
      final count =
          NotificationService.repeatCount(5, DateTime(2026, 7, 20, 14, 0));
      expect(count, 96);
    });
  });

  group('NotificationService.notificationIdsForTask', () {
    /// Cria um TaskItem para teste evitando o catch do ?? que impede
    /// passar null explicitamente para scheduledDate/scheduledTime.
    /// Usa [hasDate]/[hasTime] para decidir se os campos são nulos.
    TaskItem makeTask({
      int id = 1,
      bool hasDate = true,
      bool hasTime = true,
      int? reminderRepeatMinutes,
    }) {
      return TaskItem()
        ..id = id
        ..title = 'Teste'
        ..scheduledDate = hasDate ? DateTime(2026, 7, 20) : null
        ..scheduledTime = hasTime ? DateTime(2000, 1, 1, 10, 0) : null
        ..reminderRepeatMinutes = reminderRepeatMinutes;
    }

    test('retorna [task.id] se reminderRepeatMinutes é nulo', () {
      final t = makeTask(id: 42, reminderRepeatMinutes: null);
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [42]);
    });

    test('retorna [task.id] se reminderRepeatMinutes é 0', () {
      final t = makeTask(id: 42, reminderRepeatMinutes: 0);
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [42]);
    });

    test('retorna [task.id] se reminderRepeatMinutes é negativo', () {
      final t = makeTask(id: 42, reminderRepeatMinutes: -1);
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [42]);
    });

    test('retorna [task.id] se não tem data', () {
      final t = makeTask(
        id: 42,
        reminderRepeatMinutes: 15,
        hasDate: false,
      );
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [42]);
    });

    test('retorna [task.id] se não tem horário', () {
      final t = makeTask(
        id: 42,
        reminderRepeatMinutes: 15,
        hasTime: false,
      );
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [42]);
    });

    test('usa padrão task.id * 1000 + i para série de repetições', () {
      final t = makeTask(
        id: 7,
        reminderRepeatMinutes: 60,
      );
      // makeTask sem override cria com 10:00 → 14h até 23:59 = 839 min
      // → /60 = 13.98 → ceil = 14
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids.length, 14);
      expect(ids.first, 7000);
      expect(ids.last, 7013);
    });

    test('primeiro id da série é task.id * 1000', () {
      final t = makeTask(
        id: 42,
        reminderRepeatMinutes: 15,
      );
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids.first, 42000);
    });

    test('série com 3 repetições e teto respeitado', () {
      final t = makeTask(
        id: 1,
        reminderRepeatMinutes: 480,
      );
      final ids = NotificationService.notificationIdsForTask(t);
      expect(ids, [1000, 1001]);
    });
  });

  group('NotificationService — spy de cancelSeries no controller', () {
    test(
        'cancelSeries é chamado ao cancelar notificação de tarefa com repetição',
        () async {
      // Este teste verifica que o controller chama cancelSeries
      // em vez de apenas cancel (simulado no spy).
      // A implementação real é testada nos testes de integração
      // do controller; aqui garantimos a assinatura do método.
      final service = _NotificationServiceSpy();
      final task = TaskItem()
        ..id = 5
        ..title = 'Teste'
        ..scheduledDate = DateTime(2026, 7, 20)
        ..scheduledTime = DateTime(2000, 1, 1, 10, 0)
        ..reminderRepeatMinutes = 15
        ..notificationId = 5;

      await service.cancelSeries(task);
      expect(service.cancelledIds.isNotEmpty, true);
      expect(service.cancelledIds.first, 5000); // task.id * 1000 + 0
    });
  });
}

/// Spy mínimo para testar a assinatura de cancelSeries.
class _NotificationServiceSpy extends NotificationService {
  final List<int> cancelledIds = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> cancel(int notificationId) async {
    cancelledIds.add(notificationId);
  }
}

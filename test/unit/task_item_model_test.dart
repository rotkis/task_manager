import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/core/utils/date_helpers.dart';

void main() {
  group('TaskItem.isOverdue', () {
    test('tarefa não concluída com data passada é overdue', () {
      final task = TaskItem()
        ..title = 'Atrasada'
        ..scheduledDate = DateHelpers.yesterday()
        ..isCompleted = false;
      expect(task.isOverdue, isTrue);
    });

    test('tarefa concluída com data passada NÃO é overdue', () {
      final task = TaskItem()
        ..title = 'Feita atrasada'
        ..scheduledDate = DateHelpers.yesterday()
        ..isCompleted = true;
      expect(task.isOverdue, isFalse);
    });

    test('tarefa não concluída com data futura NÃO é overdue', () {
      final task = TaskItem()
        ..title = 'Futura'
        ..scheduledDate = DateHelpers.today().add(const Duration(days: 1))
        ..isCompleted = false;
      expect(task.isOverdue, isFalse);
    });

    test('tarefa não concluída sem data agendada NÃO é overdue', () {
      final task = TaskItem()
        ..title = 'Sem data'
        ..isCompleted = false;
      expect(task.isOverdue, isFalse);
    });

    test('tarefa de hoje com horário já passado é overdue', () {
      final now = DateTime.now();
      // Garante um horário 2 minutos no passado — funciona em qualquer hora
      final past = now.subtract(const Duration(minutes: 2));
      final task = TaskItem()
        ..title = 'Hoje atrasada'
        ..scheduledDate = DateHelpers.today()
        ..scheduledTime = DateTime(2000, 1, 1, past.hour, past.minute)
        ..isCompleted = false;
      expect(task.isOverdue, isTrue);
    });

    test('tarefa de hoje com horário futuro NÃO é overdue', () {
      final now = DateTime.now();
      // Perto da meia-noite (23:59+) não há horário futuro no mesmo dia;
      // pula o teste nesse caso para evitar falso positivo.
      if (now.hour >= 23 && now.minute >= 59) return;

      final future = now.add(const Duration(minutes: 1));
      final task = TaskItem()
        ..title = 'Hoje futura'
        ..scheduledDate = DateHelpers.today()
        ..scheduledTime = DateTime(2000, 1, 1, future.hour, future.minute)
        ..isCompleted = false;
      expect(task.isOverdue, isFalse);
    });

    test('tarefa de hoje sem horário agendado NÃO é overdue', () {
      final task = TaskItem()
        ..title = 'Hoje sem horário'
        ..scheduledDate = DateHelpers.today()
        ..isCompleted = false;
      expect(task.isOverdue, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/core/utils/share_code_codec.dart';
import 'package:task_manager/data/models/task_item.dart';

void main() {
  group('ShareCodec — round-trip encodeTasks → decodeTasks', () {
    test('codec ida e volta para tarefa genérica sem data', () {
      final original = TaskItem()
        ..title = 'Tarefa simples'
        ..type = TaskType.generic
        ..rewardPoints = 10;

      final code = encodeTasks([original]);
      expect(code, isNotEmpty);

      final decoded = decodeTasks(code);
      expect(decoded.length, 1);
      expect(decoded[0].title, 'Tarefa simples');
      expect(decoded[0].type, TaskType.generic);
      expect(decoded[0].rewardPoints, 10);
      // scheduledDate é calculado (hoje) porque não havia data original
      expect(decoded[0].scheduledDate, isNotNull);
      expect(decoded[0].scheduledTime, isNull);
    });

    test('codec ida e volta para tarefa pomodoro com data e horário', () {
      final original = TaskItem()
        ..title = 'Estudar Matemática'
        ..description = 'Capítulo 3'
        ..type = TaskType.pomodoroStudy
        ..scheduledDate = DateTime(2026, 7, 10)
        ..scheduledTime = DateTime(2000, 1, 1, 14, 30)
        ..durationMinutes = 25
        ..rewardPoints = 15
        ..isImportant = true;

      final code = encodeTasks([original]);
      final decoded = decodeTasks(code);

      expect(decoded.length, 1);
      expect(decoded[0].title, 'Estudar Matemática');
      expect(decoded[0].description, 'Capítulo 3');
      expect(decoded[0].type, TaskType.pomodoroStudy);
      expect(decoded[0].durationMinutes, 25);
      expect(decoded[0].rewardPoints, 15);
      expect(decoded[0].isImportant, true);
      // scheduledDate é offset relativo — deve ser >= hoje
      expect(decoded[0].scheduledDate, isNotNull);
      // scheduledTime preserva hora/minuto
      expect(decoded[0].scheduledTime!.hour, 14);
      expect(decoded[0].scheduledTime!.minute, 30);
    });

    test('codec ida e volta para exercício por repetições', () {
      final original = TaskItem()
        ..title = '100 flexões'
        ..type = TaskType.repsExercise
        ..targetReps = 100
        ..rewardPoints = 20;

      final code = encodeTasks([original]);
      final decoded = decodeTasks(code);

      expect(decoded.length, 1);
      expect(decoded[0].title, '100 flexões');
      expect(decoded[0].type, TaskType.repsExercise);
      expect(decoded[0].targetReps, 100);
      expect(decoded[0].rewardPoints, 20);
    });

    test('codec ida e volta para múltiplas tarefas', () {
      final task1 = TaskItem()
        ..title = 'Tarefa 1'
        ..type = TaskType.generic
        ..rewardPoints = 5;

      final task2 = TaskItem()
        ..title = 'Tarefa 2'
        ..type = TaskType.timedExercise
        ..durationMinutes = 2
        ..rewardPoints = 10;

      final code = encodeTasks([task1, task2]);
      final decoded = decodeTasks(code);

      expect(decoded.length, 2);
      expect(decoded[0].title, 'Tarefa 1');
      expect(decoded[1].title, 'Tarefa 2');
      expect(decoded[1].type, TaskType.timedExercise);
      expect(decoded[1].durationMinutes, 2);
    });

    test('código gerado é Base64 URL-safe (sem caracteres problemáticos)', () {
      final task = TaskItem()
        ..title = 'Tarefa com caracteres especiais: áéíóú ç ñ'
        ..type = TaskType.generic;

      final code = encodeTasks([task]);
      // Base64 URL-safe: A-Z a-z 0-9 - _ = (padding)
      expect(code, matches(r'^[A-Za-z0-9\-_=]+$'));
    });

    test('decodeTasks com string inválida retorna lista vazia', () {
      expect(decodeTasks('!!!invalido!!!'), isEmpty);
      expect(decodeTasks(''), isEmpty);
      expect(decodeTasks('aGVsbG8='), isEmpty); // base64 válido mas não JSON
    });

    test('syncGroupCode é preenchido com hash curto', () {
      final task = TaskItem()
        ..title = 'Teste group code'
        ..type = TaskType.generic;

      final code = encodeTasks([task]);
      final decoded = decodeTasks(code);

      expect(decoded[0].syncGroupCode, isNotNull);
      expect(decoded[0].syncGroupCode!.length, 6);
    });

    test('tarefa com título vazio é ignorada na decodificação', () {
      final code = encodeTasks([]);
      // Código de lista vazia
      final decoded = decodeTasks(code);
      expect(decoded, isEmpty);
    });

    test('descrição opcional é preservada', () {
      final task1 = TaskItem()
        ..title = 'Com descrição'
        ..description = 'Uma descrição longa aqui'
        ..type = TaskType.generic;

      final task2 = TaskItem()
        ..title = 'Sem descrição'
        ..type = TaskType.generic;

      final code = encodeTasks([task1, task2]);
      final decoded = decodeTasks(code);

      expect(decoded[0].description, 'Uma descrição longa aqui');
      expect(decoded[1].description, isNull);
    });
  });
}

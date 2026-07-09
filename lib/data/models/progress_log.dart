import 'package:isar_community/isar.dart';

// ignore_for_file: experimental_member_use
part 'progress_log.g.dart'; // gerado por: flutter pub run build_runner build

/// Um ponto de dados por dia, usado para desenhar o gráfico de linha
/// de evolução (soma de tarefas concluídas e pontos ganhos naquele dia).
@collection
class ProgressLog {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late DateTime day; // normalizado para meia-noite

  int tasksCompleted = 0;
  int pointsEarned = 0;
  int currentStreak = 0; // dias seguidos com pelo menos 1 tarefa concluída
}

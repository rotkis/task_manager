import 'package:isar_community/isar.dart';

// ignore_for_file: experimental_member_use
part 'task_item.g.dart'; // gerado por: flutter pub run build_runner build

/// Tipos de tarefa suportados. Cada tipo muda o que a UI mostra
/// no cronômetro/contador da tarefa.
enum TaskType {
  generic, // tarefa simples, só concluir
  pomodoroStudy, // estudo com tempo estilo pomodoro
  timedExercise, // exercício por tempo (ex: prancha)
  repsExercise, // exercício por repetições (ex: flexão)
}

@collection
class TaskItem {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  @enumerated
  TaskType type = TaskType.generic;

  // Agendamento
  DateTime? scheduledDate; // dia atribuído no calendário
  DateTime? scheduledTime; // horário do dia (combinado com scheduledDate)

  // Parâmetros específicos por tipo
  int? durationMinutes; // pomodoroStudy (minutos)
  int? durationSeconds; // timedExercise (segundos)
  int? targetReps; // repsExercise (repetições por série)
  int? targetSets; // repsExercise (número de séries)

  // Estado
  bool isCompleted = false;
  DateTime? completedAt;

  /// Se falso, nenhuma notificação/alarme é agendado para esta tarefa,
  /// mesmo que tenha data/horário e/ou isImportant = true.
  bool isNotificationEnabled = true;

  /// Se verdadeiro, usa alarme insistente (pacote `alarm`) em vez de
  /// notificação simples. Ver plan.md seção 2.1.
  bool isImportant = false;

  // Recompensa
  int rewardPoints = 10;

  // Notificação associada (id gerado pelo flutter_local_notifications)
  int? notificationId;

  /// ID do alarme (pacote `alarm`) para tarefas importantes.
  int? alarmId;

  // Sincronização entre usuários: tarefas compartilhadas via código
  // carregam o mesmo syncGroupCode, mas cada usuário pode editar
  // seu próprio horário/dia depois de importar.
  String? syncGroupCode;

  DateTime createdAt = DateTime.now();

  @Index()
  DateTime get indexedScheduledDate => scheduledDate ?? DateTime(1970);
}

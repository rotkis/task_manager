import 'package:isar_community/isar.dart';

import '../../core/utils/date_helpers.dart';

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
  // carregam o mesmo syncGroupCode, but cada usuário pode editar
  // seu próprio horário/dia depois de importar.
  String? syncGroupCode;

  // ─── Recorrência (Módulo 6) ────────────────────────────────────────

  /// Regra de recorrência, ex: "daily", "weekly:MON,WED,FRI", "every:3".
  /// Se nulo, a tarefa não se repete.
  String? recurrenceRule;

  /// Se esta tarefa é uma **instância** gerada de uma tarefa-modelo
  /// recorrente, [parentRecurringId] aponta para o id da tarefa-modelo.
  /// A própria tarefa-modelo tem este campo como null.
  int? parentRecurringId;

  /// Quantas vezes a tarefa foi adiada (data empurrada pra frente).
  /// Incrementado em [TaskController.updateTask] quando a nova
  /// [scheduledDate] é posterior à anterior. Resetado ao completar.
  int postponeCount = 0;

  // ─── Tags / categorias (Módulo 14) ─────────────────────────────────────

  /// Lista de tags livres (ex: "faculdade", "casa", "saúde").
  List<String> tags = [];

  DateTime createdAt = DateTime.now();

  @Index()
  DateTime get indexedScheduledDate => scheduledDate ?? DateTime(1970);

  /// Retorna `true` se a tarefa está atrasada (overdue): não concluída
  /// e com data/horário agendado já no passado.
  ///
  /// Usa a mesma lógica em [TaskCard] e [TasksScreen] — mantida em um
  /// único lugar para garantir consistência.
  bool get isOverdue {
    if (isCompleted) return false;
    if (scheduledDate == null) return false;
    final now = DateTime.now();
    final today = DateHelpers.today();

    // Data agendada anterior a hoje → atrasado
    if (DateHelpers.normalizeToDay(scheduledDate!).isBefore(today)) {
      return true;
    }

    // É hoje mas o horário já passou → atrasado
    if (scheduledTime != null &&
        DateHelpers.normalizeToDay(scheduledDate!) == today) {
      final combined = DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        scheduledTime!.hour,
        scheduledTime!.minute,
      );
      if (now.isAfter(combined)) return true;
    }

    return false;
  }
}

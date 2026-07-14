import 'package:isar_community/isar.dart';

import 'task_item.dart';

// ignore_for_file: experimental_member_use
part 'sub_task_item.g.dart'; // gerado por: flutter pub run build_runner build

/// Uma subtarefa (checklist) vinculada a uma [TaskItem] principal.
///
/// Subtarefas permitem quebrar tarefas grandes em passos menores,
/// tornando-as menos intimidantes. A conclusão da tarefa-pai é
/// independente das subtarefas (o usuário pode marcar a tarefa toda
/// como concluída mesmo com subtarefas pendentes), mas a UI mostra
/// o progresso (ex: "3/5 passos").
///
/// Cada subtarefa pode ter seu próprio [type], permitindo que passos
/// tenham naturezas diferentes (ex: "ler capítulo 3" como estudo,
/// "fazer 20 flexões" como exercício).
@collection
class SubTaskItem {
  Id id = Isar.autoIncrement;

  /// Id da tarefa-pai ([TaskItem.id]) à qual esta subtarefa pertence.
  @Index()
  late int parentTaskId;

  late String title;
  bool isCompleted = false;

  /// Ordem de exibição (0-based). Permite reordenação manual.
  int order = 0;

  /// Tipo da subtarefa. Determina o ícone/visual na lista.
  @enumerated
  TaskType type = TaskType.generic;

  /// Duração em segundos (para subtarefas do tipo [TaskType.timedExercise]).
  int? durationSeconds;

  /// Repetições por série (para subtarefas do tipo [TaskType.repsExercise]).
  int? targetReps;

  /// Número de séries (para subtarefas do tipo [TaskType.repsExercise]).
  int? targetSets;
}

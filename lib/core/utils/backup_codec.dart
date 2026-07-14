import 'dart:convert';

import '../../data/models/task_item.dart';
import '../../data/models/sub_task_item.dart';
import '../../data/models/progress_log.dart';

// ---------------------------------------------------------------------------
// Formato do arquivo de backup (plan_v2.md Módulo 9)
//
// JSON completo com todas as entidades do banco num único arquivo.
// Versão atual: 1.
//
// Estrutura:
// {
//   "version": 1,
//   "exportedAt": "2026-07-14T12:00:00.000",
//   "tasks": [ ... ],
//   "subtasks": [ ... ],
//   "progressLogs": [ ... ]
// }
//
// Ao contrário do código de compartilhamento (antigo share_codec.dart),
// este formato não compacta nem usa offset relativo — é um dump fiel dos dados.
// ---------------------------------------------------------------------------

/// Versão atual do formato de backup.
const int kBackupVersion = 1;

/// Valor sentinela para indicar que o Isar deve auto-incrementar o id.
/// Equivale a `_isarAutoIncrement` (valor 0) mas evita importar
/// isar_community na camada de utils (regra de arquitetura).
const _isarAutoIncrement = 0;

/// Resultado da decodificação de um arquivo de backup.
class BackupData {
  final int version;
  final DateTime exportedAt;
  final List<TaskItem> tasks;
  final List<SubTaskItem> subtasks;
  final List<ProgressLog> progressLogs;

  BackupData({
    required this.version,
    required this.exportedAt,
    required this.tasks,
    required this.subtasks,
    required this.progressLogs,
  });
}

/// Codifica todas as entidades em uma string JSON formatada para backup.
String encodeBackup({
  required List<TaskItem> tasks,
  required List<SubTaskItem> subtasks,
  required List<ProgressLog> progressLogs,
}) {
  final map = <String, dynamic>{
    'version': kBackupVersion,
    'exportedAt': DateTime.now().toIso8601String(),
    'tasks': tasks.map(_taskToMap).toList(),
    'subtasks': subtasks.map(_subtaskToMap).toList(),
    'progressLogs': progressLogs.map(_progressLogToMap).toList(),
  };

  return const JsonEncoder.withIndent('  ').convert(map);
}

/// Decodifica uma string JSON de backup em [BackupData].
///
/// Retorna `null` se o JSON for inválido, estiver malformado ou a versão
/// não for compatível com a atual.
BackupData? decodeBackup(String json) {
  Map<String, dynamic> data;
  try {
    data = jsonDecode(json) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }

  final version = data['version'] as int?;
  if (version == null || version < 1) return null;

  // Se a versão for maior que a atual, não podemos garantir a leitura.
  // Como a única versão existente é a 1, aceitamos qualquer versão >= 1
  // para ser forward-compatible quando novas versões surgirem.

  final tasks = <TaskItem>[];
  for (final raw in (data['tasks'] as List<dynamic>?) ?? <dynamic>[]) {
    if (raw is Map<String, dynamic>) {
      final task = _mapToTask(raw);
      if (task != null) tasks.add(task);
    }
  }

  final subtasks = <SubTaskItem>[];
  for (final raw in (data['subtasks'] as List<dynamic>?) ?? <dynamic>[]) {
    if (raw is Map<String, dynamic>) {
      final sub = _mapToSubtask(raw);
      if (sub != null) subtasks.add(sub);
    }
  }

  final progressLogs = <ProgressLog>[];
  for (final raw in (data['progressLogs'] as List<dynamic>?) ?? <dynamic>[]) {
    if (raw is Map<String, dynamic>) {
      final log = _mapToProgressLog(raw);
      if (log != null) progressLogs.add(log);
    }
  }

  final exportedAtStr = data['exportedAt'] as String? ?? '';
  return BackupData(
    version: version,
    exportedAt: DateTime.tryParse(exportedAtStr) ?? DateTime.now(),
    tasks: tasks,
    subtasks: subtasks,
    progressLogs: progressLogs,
  );
}

// ─── Serialização ────────────────────────────────────────────────────────

Map<String, dynamic> _taskToMap(TaskItem t) {
  return {
    'id': t.id,
    'title': t.title,
    if (t.description != null && t.description!.isNotEmpty)
      'description': t.description,
    'type': t.type.name,
    if (t.scheduledDate != null)
      'scheduledDate': t.scheduledDate!.toIso8601String(),
    if (t.scheduledTime != null)
      'scheduledTime': t.scheduledTime!.toIso8601String(),
    if (t.durationMinutes != null) 'durationMinutes': t.durationMinutes,
    if (t.durationSeconds != null) 'durationSeconds': t.durationSeconds,
    if (t.targetReps != null) 'targetReps': t.targetReps,
    if (t.targetSets != null) 'targetSets': t.targetSets,
    'isCompleted': t.isCompleted,
    if (t.completedAt != null) 'completedAt': t.completedAt!.toIso8601String(),
    'isNotificationEnabled': t.isNotificationEnabled,
    'isImportant': t.isImportant,
    'rewardPoints': t.rewardPoints,
    // notificationId e alarmId são runtime-specific; não exportamos
    if (t.recurrenceRule != null && t.recurrenceRule!.isNotEmpty)
      'recurrenceRule': t.recurrenceRule,
    if (t.parentRecurringId != null) 'parentRecurringId': t.parentRecurringId,
    'postponeCount': t.postponeCount,
    'tags': t.tags,
    'createdAt': t.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _subtaskToMap(SubTaskItem s) {
  return {
    'id': s.id,
    'parentTaskId': s.parentTaskId,
    'title': s.title,
    'isCompleted': s.isCompleted,
    'order': s.order,
    'type': s.type.name,
    if (s.durationSeconds != null) 'durationSeconds': s.durationSeconds,
    if (s.targetReps != null) 'targetReps': s.targetReps,
    if (s.targetSets != null) 'targetSets': s.targetSets,
  };
}

Map<String, dynamic> _progressLogToMap(ProgressLog l) {
  return {
    'id': l.id,
    'day': l.day.toIso8601String(),
    'tasksCompleted': l.tasksCompleted,
    'pointsEarned': l.pointsEarned,
    'currentStreak': l.currentStreak,
  };
}

// ─── Desserialização ──────────────────────────────────────────────────────

TaskItem? _mapToTask(Map<String, dynamic> map) {
  try {
    final title = map['title'] as String?;
    if (title == null || title.trim().isEmpty) return null;

    final typeStr = map['type'] as String? ?? 'generic';
    final type = TaskType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TaskType.generic,
    );

    final task = TaskItem()
      ..id = map['id'] as int? ?? _isarAutoIncrement
      ..title = title.trim()
      ..description = map['description'] as String?
      ..type = type
      ..scheduledDate = _parseDateTime(map['scheduledDate'] as String?)
      ..scheduledTime = _parseDateTime(map['scheduledTime'] as String?)
      ..durationMinutes = map['durationMinutes'] as int?
      ..durationSeconds = map['durationSeconds'] as int?
      ..targetReps = map['targetReps'] as int?
      ..targetSets = map['targetSets'] as int?
      ..isCompleted = map['isCompleted'] as bool? ?? false
      ..completedAt = _parseDateTime(map['completedAt'] as String?)
      ..isNotificationEnabled = map['isNotificationEnabled'] as bool? ?? true
      ..isImportant = map['isImportant'] as bool? ?? false
      ..rewardPoints = map['rewardPoints'] as int? ?? 10
      ..recurrenceRule = map['recurrenceRule'] as String?
      ..parentRecurringId = map['parentRecurringId'] as int?
      ..postponeCount = map['postponeCount'] as int? ?? 0
      ..tags =
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              []
      ..createdAt =
          _parseDateTime(map['createdAt'] as String?) ?? DateTime.now();

    return task;
  } catch (_) {
    return null;
  }
}

SubTaskItem? _mapToSubtask(Map<String, dynamic> map) {
  try {
    final title = map['title'] as String?;
    if (title == null || title.trim().isEmpty) return null;

    final typeStr = map['type'] as String? ?? 'generic';
    final type = TaskType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TaskType.generic,
    );

    return SubTaskItem()
      ..id = map['id'] as int? ?? _isarAutoIncrement
      ..parentTaskId = map['parentTaskId'] as int? ?? 0
      ..title = title.trim()
      ..isCompleted = map['isCompleted'] as bool? ?? false
      ..order = map['order'] as int? ?? 0
      ..type = type
      ..durationSeconds = map['durationSeconds'] as int?
      ..targetReps = map['targetReps'] as int?
      ..targetSets = map['targetSets'] as int?;
  } catch (_) {
    return null;
  }
}

ProgressLog? _mapToProgressLog(Map<String, dynamic> map) {
  try {
    final dayStr = map['day'] as String?;
    if (dayStr == null) return null;
    final day = DateTime.tryParse(dayStr);
    if (day == null) return null;

    return ProgressLog()
      ..id = map['id'] as int? ?? _isarAutoIncrement
      ..day = day
      ..tasksCompleted = map['tasksCompleted'] as int? ?? 0
      ..pointsEarned = map['pointsEarned'] as int? ?? 0
      ..currentStreak = map['currentStreak'] as int? ?? 0;
  } catch (_) {
    return null;
  }
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

import 'dart:convert';

import '../constants/app_constants.dart';
import '../../data/models/task_item.dart';

// ---------------------------------------------------------------------------
// Formato do código de compartilhamento (plan.md §2.2)
//
// Usamos um JSON compacto (chaves curtas) para manter o payload pequeno.
// Datas são guardadas como offset relativo (dias a partir de hoje)
// para que a importação faça sentido em qualquer dia.
//
// Mapa de chaves:
//   t   – title
//   d   – description (opcional)
//   y   – type (string curta: "gen","pom","tim","rep")
//   D   – offset da scheduledDate em dias (0 = hoje, 1 = amanhã, etc.)
//   H   – scheduledTime no formato "HH:mm" (opcional)
//   du  – durationMinutes (opcional)
//   r   – targetReps (opcional)
//   p   – rewardPoints
//   i   – isImportant (opcional, default false)
//   sg  – syncGroupCode (opcional, só para rastreio visual)
// ---------------------------------------------------------------------------

const _typeMap = {
  TaskType.generic: 'gen',
  TaskType.pomodoroStudy: 'pom',
  TaskType.timedExercise: 'tim',
  TaskType.repsExercise: 'rep',
};

const _reverseTypeMap = {
  'gen': TaskType.generic,
  'pom': TaskType.pomodoroStudy,
  'tim': TaskType.timedExercise,
  'rep': TaskType.repsExercise,
};

/// Codifica uma lista de [TaskItem] em uma string Base64 URL-safe
/// para ser copiada/colada ou transformada em QR code.
String encodeTasks(List<TaskItem> tasks) {
  final today = _normalize(DateTime.now());
  final list = tasks.map((task) {
    final relativeDays = task.scheduledDate != null
        ? _normalize(task.scheduledDate!).difference(today).inDays
        : 0;

    final timeStr = task.scheduledTime != null
        ? '${_pad(task.scheduledTime!.hour)}:${_pad(task.scheduledTime!.minute)}'
        : null;

    final map = <String, dynamic>{
      't': task.title,
      'y': _typeMap[task.type] ?? 'gen',
      'D': relativeDays,
      'p': task.rewardPoints,
    };

    if (task.description != null && task.description!.isNotEmpty) {
      map['d'] = task.description;
    }
    if (timeStr != null) {
      map['H'] = timeStr;
    }
    if (task.durationMinutes != null) {
      map['du'] = task.durationMinutes;
    }
    if (task.targetReps != null) {
      map['r'] = task.targetReps;
    }
    if (task.isImportant) {
      map['i'] = true;
    }
    if (task.syncGroupCode != null) {
      map['sg'] = task.syncGroupCode;
    }

    return map;
  }).toList();

  final jsonStr = jsonEncode(list);
  return base64Url.encode(utf8.encode(jsonStr)).replaceAll('=', '');
}

/// Decodifica uma string de código em uma lista de [TaskItem] parciais.
/// As tarefas retornadas têm dados preenchidos mas **não** estão salvas
/// no banco — o repositório deve persistí-las.
///
/// Os campos [scheduledDate] e [scheduledTime] já vêm como DateTime
/// absolutos (calculados a partir do offset relativo + now).
/// O campo [syncGroupCode] é preenchido com um hash curto do payload
/// para agrupamento visual.
List<TaskItem> decodeTasks(String code) {
  // Tenta decodificar; se falhar, retorna lista vazia (erro silencioso)
  String jsonStr;
  try {
    final padded = _addBase64Padding(code);
    final bytes = base64Url.decode(padded);
    jsonStr = utf8.decode(bytes);
  } catch (_) {
    return [];
  }

  List<dynamic> list;
  try {
    list = jsonDecode(jsonStr) as List<dynamic>;
  } catch (_) {
    return [];
  }

  final today = _normalize(DateTime.now());
  final payloadHash = _shortHash(code);

  final results = <TaskItem>[];
  for (final raw in list) {
    if (raw is! Map<String, dynamic>) continue;
    try {
      final task = _mapToTask(raw, today, payloadHash);
      if (task != null) results.add(task);
    } catch (_) {
      // Ignora itens malformados
    }
  }
  return results;
}

/// Adiciona padding `=` à string base64 para que o comprimento seja
/// múltiplo de 4, exigido por [base64Url.decode].
String _addBase64Padding(String input) {
  final mod = input.length % 4;
  if (mod == 0) return input;
  return input.padRight(input.length + (4 - mod), '=');
}

/// Gera um hash curto (6 caracteres hex) determinístico para agrupar
/// visualmente tarefas vindas do mesmo código.
///
/// Usa FNV-1a 32 bits sobre os bytes UTF-8 da string, garantindo que
/// o mesmo código produza o mesmo hash em qualquer plataforma/runtime.
String _shortHash(String code) {
  const fnvOffsetBasis = 0x811C9DC5; // 2166136261
  const fnvPrime = 0x01000193; // 16777619

  final bytes = code.codeUnits;
  var hash = fnvOffsetBasis;
  for (final byte in bytes) {
    hash ^= byte & 0xFF; // FNV-1a: XOR antes da multiplicação
    hash = (hash * fnvPrime) & 0xFFFFFFFF; // mantém 32 bits
  }

  // Converte para string hex de 6 caracteres
  return hash.toRadixString(16).padLeft(6, '0').substring(0, 6);
}

TaskItem? _mapToTask(Map<String, dynamic> map, DateTime today, String hash) {
  final title = map['t'] as String?;
  if (title == null || title.trim().isEmpty) return null;

  final typeShort = map['y'] as String? ?? 'gen';
  final type = _reverseTypeMap[typeShort] ?? TaskType.generic;

  final relativeDays = map['D'] as int? ?? 0;
  final scheduledDate = today.add(Duration(days: relativeDays));

  DateTime? scheduledTime;
  final timeStr = map['H'] as String?;
  if (timeStr != null) {
    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        scheduledTime = DateTime(2000, 1, 1, hour, minute);
      }
    }
  }

  final rewardPoints = map['p'] as int? ?? AppConstants.defaultRewardPoints;
  final isImportant = map['i'] as bool? ?? false;
  final description = map['d'] as String?;
  final durationMinutes = map['du'] as int?;
  final targetReps = map['r'] as int?;
  final syncGroupCode = map['sg'] as String? ?? hash;

  final task = TaskItem()
    ..title = title.trim()
    ..description = description
    ..type = type
    ..scheduledDate = scheduledDate
    ..scheduledTime = scheduledTime
    ..durationMinutes = durationMinutes
    ..targetReps = targetReps
    ..rewardPoints = rewardPoints
    ..isImportant = isImportant
    ..syncGroupCode = syncGroupCode;

  return task;
}

DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String _pad(int n) => n.toString().padLeft(2, '0');

/// Resultado do parse de uma regra de recorrência.
class RecurrenceRule {
  /// Tipo da recorrência.
  final RecurrenceType type;

  /// Dias da semana (1=segunda … 7=domingo) para recorrência semanal.
  final List<int> weekDays;

  /// Intervalo em dias para recorrência customizada (every:N).
  final int intervalDays;

  const RecurrenceRule({
    required this.type,
    this.weekDays = const [],
    this.intervalDays = 1,
  });

  /// Nome legível para exibição na UI.
  String get displayName {
    switch (type) {
      case RecurrenceType.none:
        return 'Não repete';
      case RecurrenceType.daily:
        return 'Diária';
      case RecurrenceType.weekly:
        final days = weekDays.map(weekDayName).join(', ');
        return 'Semanal ($days)';
      case RecurrenceType.everyNDays:
        return 'A cada $intervalDays dias';
    }
  }

  /// Gera as datas (meia-noite) em que a tarefa deve ocorrer no intervalo
  /// [start] (inclusive) .. [end] (inclusive), considerando a data de
  /// referência [referenceDate] (normalmente a data de criação da tarefa).
  List<DateTime> generateDates({
    required DateTime referenceDate,
    required DateTime start,
    required DateTime end,
  }) {
    if (type == RecurrenceType.none) return [];

    final ref =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);

    switch (type) {
      case RecurrenceType.daily:
        return _generateDaily(ref, from, to);
      case RecurrenceType.weekly:
        return _generateWeekly(ref, from, to);
      case RecurrenceType.everyNDays:
        return _generateEveryNDays(ref, from, to);
      default:
        return [];
    }
  }

  List<DateTime> _generateDaily(DateTime ref, DateTime from, DateTime to) {
    final dates = <DateTime>[];
    var current = DateTime(ref.year, ref.month, ref.day);
    while (!current.isAfter(to)) {
      if (!current.isBefore(from)) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  List<DateTime> _generateWeekly(DateTime ref, DateTime from, DateTime to) {
    final dates = <DateTime>[];
    var current = DateTime(ref.year, ref.month, ref.day);
    while (!current.isAfter(to)) {
      if (!current.isBefore(from)) {
        // weekday: 1=Monday … 7=Sunday
        if (weekDays.contains(current.weekday)) {
          dates.add(current);
        }
      }
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  List<DateTime> _generateEveryNDays(DateTime ref, DateTime from, DateTime to) {
    final dates = <DateTime>[];
    var current = DateTime(ref.year, ref.month, ref.day);
    while (!current.isAfter(to)) {
      if (!current.isBefore(from)) {
        dates.add(current);
      }
      current = current.add(Duration(days: intervalDays));
    }
    return dates;
  }

  // ─── Utilitários ──────────────────────────────────────────────────

  /// Nome curto do dia da semana (1=segunda … 7=domingo).
  static String weekDayName(int wd) {
    const names = [
      '',
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom',
    ];
    return (wd >= 1 && wd <= 7) ? names[wd] : '?';
  }

  /// Abreviação de 2 caracteres para usar no código.
  static String weekDayAbbr(int wd) {
    const abbr = [
      '',
      'MO',
      'TU',
      'WE',
      'TH',
      'FR',
      'SA',
      'SU',
    ];
    return (wd >= 1 && wd <= 7) ? abbr[wd] : '??';
  }

  /// Converte abreviação de 2 caracteres para weekday (1-7).
  /// Retorna null se inválido.
  static int? parseWeekDayAbbr(String s) {
    const map = <String, int>{
      'MO': 1,
      'TU': 2,
      'WE': 3,
      'TH': 4,
      'FR': 5,
      'SA': 6,
      'SU': 7,
    };
    return map[s.toUpperCase()];
  }
}

/// Tipos de recorrência.
enum RecurrenceType {
  none,
  daily,
  weekly,
  everyNDays,
}

/// Faz o parse de uma string de regra de recorrência.
///
/// Formatos aceitos:
/// - `null` ou vazio → [RecurrenceType.none]
/// - `"daily"` → [RecurrenceType.daily]
/// - `"weekly:MON,WED,FRI"` → [RecurrenceType.weekly] com dias
/// - `"every:3"` → [RecurrenceType.everyNDays] com intervalo de 3 dias
RecurrenceRule parseRecurrenceRule(String? rule) {
  if (rule == null || rule.trim().isEmpty) {
    return const RecurrenceRule(type: RecurrenceType.none);
  }

  final trimmed = rule.trim();

  if (trimmed == 'daily') {
    return const RecurrenceRule(type: RecurrenceType.daily);
  }

  if (trimmed.startsWith('weekly:')) {
    final daysPart = trimmed.substring('weekly:'.length);
    final abbrList =
        daysPart.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final days = <int>[];
    for (final abbr in abbrList) {
      final wd = RecurrenceRule.parseWeekDayAbbr(abbr);
      if (wd != null) days.add(wd);
    }
    if (days.isEmpty) {
      return const RecurrenceRule(type: RecurrenceType.none);
    }
    return RecurrenceRule(type: RecurrenceType.weekly, weekDays: days);
  }

  if (trimmed.startsWith('every:')) {
    final numStr = trimmed.substring('every:'.length).trim();
    final interval = int.tryParse(numStr);
    if (interval == null || interval < 1) {
      return const RecurrenceRule(type: RecurrenceType.none);
    }
    return RecurrenceRule(
        type: RecurrenceType.everyNDays, intervalDays: interval);
  }

  return const RecurrenceRule(type: RecurrenceType.none);
}

/// Serializa uma [RecurrenceRule] de volta para string.
String serializeRecurrenceRule(RecurrenceRule rule) {
  switch (rule.type) {
    case RecurrenceType.none:
      return '';
    case RecurrenceType.daily:
      return 'daily';
    case RecurrenceType.weekly:
      final abbrs = rule.weekDays.map(RecurrenceRule.weekDayAbbr).join(',');
      return 'weekly:$abbrs';
    case RecurrenceType.everyNDays:
      return 'every:${rule.intervalDays}';
  }
}

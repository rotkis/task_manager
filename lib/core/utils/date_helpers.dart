/// Funções auxiliares para normalização e manipulação de datas,
/// sem conflitar com o `date_utils` do Material.
class DateHelpers {
  DateHelpers._();

  /// Retorna a data normalizada para meia-noite (UTC), preservando
  /// apenas ano, mês e dia.
  static DateTime normalizeToDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Hoje à meia-noite.
  static DateTime today() => normalizeToDay(DateTime.now());

  /// Ontem à meia-noite.
  static DateTime yesterday() {
    final now = DateTime.now();
    return normalizeToDay(now.subtract(const Duration(days: 1)));
  }

  /// Combina [date] (só dia) com [time] (hora/minuto) em um único DateTime.
  /// Se [time] for null, retorna [date] à meia-noite.
  static DateTime? combineDateAndTime(DateTime? date, DateTime? time) {
    if (date == null) return null;
    if (time == null) return normalizeToDay(date);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

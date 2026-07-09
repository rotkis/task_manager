import 'dart:async';

import 'package:isar_community/isar.dart';

import '../isar/isar_service.dart';
import '../models/progress_log.dart';
import '../../core/utils/date_helpers.dart';

/// Camada de acesso a dados para [ProgressLog].
class ProgressRepository {
  Isar get _isar => IsarService.instance;

  /// Incrementa o log de progresso do dia corrente com [points] pontos.
  /// Cria um novo registro se o dia ainda não existir, ou atualiza o
  /// existente. Também calcula e atualiza a streak (dias consecutivos
  /// com tasksCompleted > 0).
  Future<void> incrementToday(int points) async {
    final today = DateHelpers.today();

    await _isar.writeTxn(() async {
      // Busca ou cria o log de hoje
      ProgressLog? log = await _isar.progressLogs.getByDay(today);

      log ??= ProgressLog()..day = today;

      log.tasksCompleted += 1;
      log.pointsEarned += points;

      // Calcula streak
      final yesterday = DateHelpers.yesterday();
      final yesterdayLog = await _isar.progressLogs.getByDay(yesterday);

      if (yesterdayLog != null && yesterdayLog.tasksCompleted > 0) {
        log.currentStreak = yesterdayLog.currentStreak + 1;
      } else {
        log.currentStreak = 1;
      }

      await _isar.progressLogs.putByDay(log);
    });
  }

  /// Stream de logs de progresso entre [start] e [end] (ambos
  /// normalizados à meia-noite), ordenados por dia.
  Stream<List<ProgressLog>> watchRange(DateTime start, DateTime end) {
    final s = DateHelpers.normalizeToDay(start);
    final e = DateHelpers.normalizeToDay(end);
    return _isar.progressLogs
        .where()
        .filter()
        .dayBetween(s, e)
        .sortByDay()
        .watch(fireImmediately: true);
  }

  /// Busca o log de um dia específico.
  Future<ProgressLog?> getByDay(DateTime day) async {
    return _isar.progressLogs.getByDay(DateHelpers.normalizeToDay(day));
  }
}

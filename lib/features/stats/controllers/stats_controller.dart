import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart' show FlSpot;

import '../../../core/utils/date_helpers.dart';
import '../../../data/models/progress_log.dart';
import '../../../data/repositories/progress_repository.dart';

/// Período de visualização do gráfico de evolução.
enum ChartPeriod { week, month, all }

/// Gerencia o estado da tela de estatísticas/evolução.
///
/// Escuta o repositório de progresso e expõe listas de pontos para o
/// gráfico de linha, o streak atual e totais por período.
class StatsController extends ChangeNotifier {
  final ProgressRepository _progressRepo;

  StreamSubscription<List<ProgressLog>>? _sub;

  /// Período atualmente selecionado.
  ChartPeriod _period = ChartPeriod.week;

  /// Logs recebidos do stream (já ordenados por dia).
  List<ProgressLog> _logs = [];

  bool _disposed = false;

  StatsController({
    ProgressRepository? progressRepo,
  }) : _progressRepo = progressRepo ?? ProgressRepository();

  // ─── Getters ────────────────────────────────────────────────────────

  ChartPeriod get period => _period;

  /// Streak atual (último log ou 0 se não houver).
  int get currentStreak {
    if (_logs.isEmpty) return 0;
    // O streak do dia mais recente (último da lista ordenada)
    return _logs.last.currentStreak;
  }

  /// Total de pontos no período selecionado.
  int get totalPointsInPeriod =>
      _periodLogs.fold(0, (sum, log) => sum + log.pointsEarned);

  /// Total de tarefas concluídas no período selecionado.
  int get totalTasksInPeriod =>
      _periodLogs.fold(0, (sum, log) => sum + log.tasksCompleted);

  /// Logs filtrados pelo período selecionado.
  List<ProgressLog> get _periodLogs {
    final start = _periodStart();
    if (start == null) return _logs; // "all" ou sem limite
    return _logs.where((log) => !log.day.isBefore(start)).toList();
  }

  /// Data de início efetiva do período (usada como referência para os labels).
  DateTime get chartStart {
    // Se `_periodStart()` retorna null ("all"), usamos o primeiro log disponível
    return _periodStart() ??
        (_logs.isNotEmpty ? _logs.first.day : DateHelpers.today());
  }

  /// Número de dias cobertos pelo período atual.
  int get chartDayCount {
    final start = _periodStart();
    if (start != null) {
      // week / month: dias corridos do início até hoje
      return DateTime.now().difference(start).inDays + 1;
    }
    // "all": baseado no range real dos dados
    if (_logs.isEmpty) return 0;
    return _logs.last.day.difference(_logs.first.day).inDays + 1;
  }

  /// Pontos do gráfico: lista de [FlSpot] (x = dia do período, y = pontos).
  List<FlSpot> get chartSpots {
    final logs = _periodLogs;
    if (logs.isEmpty) return [];

    final start = chartStart;
    final dayCount = chartDayCount;
    if (dayCount <= 0) return [];

    // Constrói pontos para cada dia do período, preenchendo gaps com 0
    final spots = <FlSpot>[];
    for (int i = 0; i < dayCount; i++) {
      final day = start.add(Duration(days: i));
      final log = logs.where((l) => l.day == day).firstOrNull;
      spots.add(FlSpot(i.toDouble(), (log?.pointsEarned ?? 0).toDouble()));
    }
    return spots;
  }

  /// Labels do eixo X: exibe a cada N dias.
  List<String> get dayLabels {
    final count = chartDayCount;
    if (count <= 0) return [];
    if (count <= 7) return List.generate(count, (i) => '${i + 1}');
    // A cada ~5 dias para períodos longos
    final step = (count / 5).ceil();
    return List.generate(count, (i) => i % step == 0 ? '${i + 1}' : '');
  }

  // ─── Período ────────────────────────────────────────────────────────

  /// Data de início do período selecionado.
  DateTime? _periodStart() {
    final today = DateHelpers.today();
    switch (_period) {
      case ChartPeriod.week:
        return today.subtract(const Duration(days: 6));
      case ChartPeriod.month:
        return today.subtract(const Duration(days: 29));
      case ChartPeriod.all:
        return null; // sem limite inferior
    }
  }

  /// Altera o período e reinicia a escuta se necessário.
  void setPeriod(ChartPeriod newPeriod) {
    _period = newPeriod;
    notifyListeners();
  }

  // ─── Inicialização ──────────────────────────────────────────────────

  /// Inicia a escuta do stream de progresso.
  void init() {
    _sub?.cancel();
    // Escuta todos os logs; o controller filtra por período
    _sub = _progressRepo
        .watchRange(
      DateTime(1970),
      DateTime(2100),
    )
        .listen((logs) {
      if (_disposed) return;
      _logs = logs;
      notifyListeners();
    });
  }

  // ─── Limpeza ────────────────────────────────────────────────────────

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/stats_controller.dart';
import '../widgets/progress_line_chart.dart';
import '../widgets/streak_badge.dart';

/// Tela de estatísticas/evolução.
///
/// Exibe:
/// - Streak atual ("🔥 N dias")
/// - Totais do período (pontos da semana/mês, tarefas concluídas)
/// - Gráfico de linha de pontos por dia com seletor de período
///
/// Atualiza em tempo real via stream do Isar — sem necessidade de
/// recarregar a tela.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final StatsController _statsController;

  @override
  void initState() {
    super.initState();
    _statsController = StatsController();
    _statsController.init();
  }

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _statsController,
      child: Consumer<StatsController>(
        builder: (context, controller, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Streak ────────────────────────────────────
              Center(child: StreakBadge(streak: controller.currentStreak)),
              const SizedBox(height: 24),

              // ─── Totais do período ─────────────────────────
              _buildTotalsRow(context, controller),
              const SizedBox(height: 24),

              // ─── Gráfico ────────────────────────────────────
              ProgressLineChart(controller: controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalsRow(BuildContext context, StatsController controller) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star,
            label: 'Pontos no período',
            value: '${controller.totalPointsInPeriod}',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.check_circle_outline,
            label: 'Tarefas concluídas',
            value: '${controller.totalTasksInPeriod}',
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

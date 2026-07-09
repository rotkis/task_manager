import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../controllers/stats_controller.dart';

/// Gráfico de linha mostrando pontos acumulados por dia.
///
/// Inclui um seletor de período (7 / 30 / tudo) na parte superior.
/// Atualiza em tempo real via stream do Isar.
class ProgressLineChart extends StatelessWidget {
  final StatsController controller;

  const ProgressLineChart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = controller.chartSpots;
    final labels = controller.dayLabels;
    final color = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Seletor de período ────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ChartPeriod>(
            segments: const [
              ButtonSegment(value: ChartPeriod.week, label: Text('7 dias')),
              ButtonSegment(value: ChartPeriod.month, label: Text('30 dias')),
              ButtonSegment(value: ChartPeriod.all, label: Text('Tudo')),
            ],
            selected: {controller.period},
            onSelectionChanged: (selected) {
              controller.setPeriod(selected.first);
            },
          ),
        ),
        const SizedBox(height: 16),

        // ─── Gráfico ────────────────────────────────────────
        if (spots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'Nenhum dado no período',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 16,
                top: 8,
                bottom: 4,
              ),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: _maxY(spots),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _yInterval(spots),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: _yInterval(spots),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          final label = labels[idx];
                          if (label.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: color,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final day = _dayLabel(spot.x.toInt());
                          return LineTooltipItem(
                            '$day\n${spot.y.toInt()} pts',
                            TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _maxY(List<FlSpot> spots) {
    final max = spots.fold(0.0, (m, s) => s.y > m ? s.y : m);
    if (max == 0) return 10;
    return (max * 1.2).ceilToDouble();
  }

  double _yInterval(List<FlSpot> spots) {
    final maxY = _maxY(spots);
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    return (maxY / 5).ceilToDouble();
  }

  String _dayLabel(int index) {
    final start = controller.chartStart;
    final day = start.add(Duration(days: index));
    return '${day.day}/${day.month}';
  }
}

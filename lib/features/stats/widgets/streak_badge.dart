import 'package:flutter/material.dart';

/// Widget pequeno que exibe a streak atual no formato "🔥 N dias".
class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _streakColor(streak).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                streak > 0 ? '$streak dias' : 'Nenhum',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _streakColor(streak),
                ),
              ),
              Text(
                streak == 1 ? 'dia seguido' : 'dias seguidos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _streakColor(int streak) {
    if (streak == 0) return Colors.grey;
    if (streak >= 7) return Colors.orange;
    if (streak >= 3) return Colors.amber.shade700;
    return Colors.brown;
  }
}

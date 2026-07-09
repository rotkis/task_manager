import 'package:flutter/material.dart';

/// Contador manual de repetições com suporte a séries.
///
/// O usuário define [targetReps] (repetições por série) e [targetSets]
/// (quantas séries). A cada série, o contador vai de 0 até targetReps.
/// Ao completar uma série, avança para a próxima automaticamente.
/// Quando todas as séries são concluídas, executa [onComplete].
class RepCounterWidget extends StatefulWidget {
  /// Repetições por série.
  final int targetReps;

  /// Número de séries.
  final int targetSets;

  /// Chamado quando TODAS as séries são concluídas.
  final VoidCallback? onComplete;

  const RepCounterWidget({
    super.key,
    required this.targetReps,
    this.targetSets = 3,
    this.onComplete,
  });

  @override
  State<RepCounterWidget> createState() => _RepCounterWidgetState();
}

class _RepCounterWidgetState extends State<RepCounterWidget> {
  int _currentSet = 1; // série atual (1-based)
  int _currentReps = 0;

  bool get _allComplete => _currentSet > widget.targetSets;

  void _increment() {
    if (_allComplete) return;

    setState(() => _currentReps++);

    if (_currentReps >= widget.targetReps) {
      // Série concluída — avança ou finaliza
      if (_currentSet >= widget.targetSets) {
        // Todas as séries concluídas
        widget.onComplete?.call();
      } else {
        // Próxima série
        setState(() {
          _currentSet++;
          _currentReps = 0;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _currentSet = 1;
      _currentReps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título da série
          Text(
            _allComplete
                ? 'Treino concluído!'
                : 'Série $_currentSet de ${widget.targetSets}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Contador de repetições
          Text(
            _allComplete
                ? '${widget.targetReps * widget.targetSets} reps'
                : '$_currentReps / ${widget.targetReps}',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Status
          if (!_allComplete)
            Text(
              'Faltam ${widget.targetReps - _currentReps} reps',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),

          // Indicador de séries
          if (!_allComplete) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.targetSets, (i) {
                final num = i + 1;
                final done = num < _currentSet;
                final active = num == _currentSet;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: done
                        ? theme.colorScheme.primary
                        : active
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$num',
                    style: TextStyle(
                      color: done || active
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }),
            ),
          ],

          const SizedBox(height: 16),

          // Barra de progresso da série atual
          if (!_allComplete)
            LinearProgressIndicator(
              value:
                  widget.targetReps > 0 ? _currentReps / widget.targetReps : 0,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

          const SizedBox(height: 24),

          // Botão "+1"
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _allComplete ? null : _increment,
              icon: Icon(_allComplete ? Icons.check : Icons.add),
              label: Text(
                _allComplete ? 'Concluído' : '+1',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reset
          TextButton.icon(
            onPressed: (_currentReps > 0 || _currentSet > 1) ? _reset : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar treino'),
          ),
        ],
      ),
    );
  }
}

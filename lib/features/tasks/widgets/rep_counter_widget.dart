import 'package:flutter/material.dart';

/// Contador manual de repetições.
///
/// Exibe progresso `atual / meta` com uma barra de progresso
/// e um botão "+1". Quando o contador atinge a meta, executa
/// [onComplete] e o botão "+1" é desabilitado.
class RepCounterWidget extends StatefulWidget {
  /// Número alvo de repetições.
  final int targetReps;

  /// Chamado quando o usuário atinge a meta.
  final VoidCallback? onComplete;

  const RepCounterWidget({
    super.key,
    required this.targetReps,
    this.onComplete,
  });

  @override
  State<RepCounterWidget> createState() => _RepCounterWidgetState();
}

class _RepCounterWidgetState extends State<RepCounterWidget> {
  int _currentReps = 0;

  bool get _isComplete => _currentReps >= widget.targetReps;

  void _increment() {
    if (_isComplete) return;
    setState(() => _currentReps++);
    if (_isComplete) {
      widget.onComplete?.call();
    }
  }

  void _reset() {
    setState(() => _currentReps = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = widget.targetReps - _currentReps;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contador
          Text(
            '$_currentReps / ${widget.targetReps}',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            remaining > 0 ? 'Faltam $remaining' : 'Completo!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: remaining > 0
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Barra de progresso
          LinearProgressIndicator(
            value: widget.targetReps > 0 ? _currentReps / widget.targetReps : 0,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),

          // Botão "+1"
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isComplete ? null : _increment,
              icon: const Icon(Icons.add),
              label: Text(
                _isComplete ? 'Concluído' : '+1',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reset
          TextButton.icon(
            onPressed: _currentReps > 0 ? _reset : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }
}

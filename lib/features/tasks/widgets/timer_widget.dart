import 'dart:async';
import 'package:flutter/material.dart';

/// Cronômetro regressivo reutilizável.
///
/// Exibe o tempo restante no formato MM:SS e aceita pause/resume
/// via botão. Executa [onFinish] quando o tempo chega a zero.
///
/// Se [breakDurationMinutes] for maior que 0, o cronômetro opera
/// em duas fases: foco → pausa → [onFinish] (ciclo pomodoro).
class TimerWidget extends StatefulWidget {
  /// Duração total em minutos (fase de foco).
  final int durationMinutes;

  /// Duração da pausa em minutos (0 = sem pausa).
  final int breakDurationMinutes;

  /// Chamado quando o ciclo completo (foco + opcional pausa) encerra.
  final VoidCallback? onFinish;

  /// Chamado quando o usuário cancela manualmente.
  final VoidCallback? onCancel;

  const TimerWidget({
    super.key,
    required this.durationMinutes,
    this.breakDurationMinutes = 0,
    this.onFinish,
    this.onCancel,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isBreak = false; // true = fase de pausa

  int get _totalSeconds => widget.durationMinutes * 60;
  int get _breakSeconds => widget.breakDurationMinutes * 60;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        // Se estávamos no foco e há pausa configurada, inicia a pausa
        if (!_isBreak && _breakSeconds > 0) {
          setState(() {
            _isBreak = true;
            _remainingSeconds = _breakSeconds;
            _isRunning = true;
          });
          _startTimer();
        } else {
          _isRunning = false;
          widget.onFinish?.call();
          if (mounted) setState(() {});
        }
        return;
      }
      if (mounted) setState(() => _remainingSeconds--);
    });
  }

  void _togglePause() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    } else {
      _startTimer();
    }
    setState(() {});
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Progresso global: (segundos decorridos) / (segundos totais).
  double get _globalProgress {
    final total = _totalSeconds + _breakSeconds;
    if (total == 0) return 0;
    final elapsed = total - _remainingSeconds;
    return elapsed / total;
  }

  /// Progresso da fase atual (foco ou pausa).
  double get _phaseProgress {
    final phaseTotal = _isBreak ? _breakSeconds : _totalSeconds;
    if (phaseTotal == 0) return 0;
    return _remainingSeconds / phaseTotal;
  }

  String get _statusText {
    if (_remainingSeconds <= 0) {
      return 'Ciclo completo!';
    }
    return _isBreak ? 'Hora do intervalo ☕' : 'Foco';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = _remainingSeconds <= 0 && !_isBreak;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status / fase
          Text(
            _statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _isBreak
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Temporizador
          Text(
            _formattedTime,
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _remainingSeconds <= 0 && !_isBreak
                  ? theme.colorScheme.error
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Barra de progresso global (apenas se tem pausa)
          if (_breakSeconds > 0) ...[
            LinearProgressIndicator(
              value: _globalProgress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              color: _isBreak
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
          ],

          // Barra de progresso da fase atual
          if (_remainingSeconds > 0 || _isBreak)
            LinearProgressIndicator(
              value: 1.0 - _phaseProgress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: _isBreak
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
            ),
          const SizedBox(height: 24),

          // Botões
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isFinished) ...[
                IconButton(
                  icon:
                      Icon(_isRunning ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 48,
                  onPressed: _togglePause,
                ),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: const Icon(Icons.stop_circle),
                iconSize: 48,
                onPressed: () {
                  _timer?.cancel();
                  _isRunning = false;
                  widget.onCancel?.call();
                },
              ),
            ],
          ),

          if (isFinished)
            Text(
              'Ciclo completo!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

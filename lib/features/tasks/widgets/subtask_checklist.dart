import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/sub_task_item.dart';
import '../../../data/models/task_item.dart';
import '../controllers/task_controller.dart';
import 'timer_widget.dart';
import 'rep_counter_widget.dart';

/// Checklist de subtarefas para uma tarefa.
///
/// **Modo formulário** ([showAddField] = true): carrega as subtarefas uma vez
/// na inicialização via [TaskRepository.getSubtasks] e gerencia o estado
/// localmente (add/toggle/delete atualiza tanto o estado local quanto o
/// banco). Não usa stream do Isar para evitar conflitos com
/// [pumpAndSettle] em testes.
///
/// Quando [parentTaskId] é 0 (modo criação), as subtarefas adicionadas
/// ficam apenas em memória — não são persistidas ao Isar. Use
/// [savePendingToRepo] após a criação da tarefa para salvá-las com o
/// id correto.
///
/// **Modo card** ([showAddField] = false): se [initialSubtasks] for
/// fornecido, exibe as subtarefas com checkboxes interativos e chama
/// [onToggleSubtask] quando o usuário alterna o estado. Se não houver
/// [initialSubtasks], exibe apenas o cabeçalho de progresso
/// ("Passos: N/M") sem consulta assíncrona.
class SubtaskChecklist extends StatefulWidget {
  final int parentTaskId;

  /// Se true, mostra o campo de adicionar novo passo (modo formulário).
  /// Se false, mostra só a lista (modo card).
  final bool showAddField;

  /// Quando true, permite selecionar o tipo da subtarefa ao adicionar.
  final bool showTypeSelector;

  /// Texto de progresso opcional para modo card (ex: "3/5").
  /// Se omitido, fica "0/0".
  final String? progressText;

  /// Lista de subtarefas para exibição no modo card.
  /// Quando fornecido e [showAddField] é false, renderiza checkboxes
  /// interativos e usa [onToggleSubtask] para alternar o estado.
  final List<SubTaskItem>? initialSubtasks;

  /// Callback chamado quando o usuário alterna uma subtarefa no modo card.
  final ValueChanged<int>? onToggleSubtask;

  /// Callback chamado sempre que a lista de subtarefas muda em modo
  /// criação (parentTaskId == 0). Útil para o [TaskForm] coletar
  /// as subtarefas pendentes e persistí-las após criar a tarefa.
  final ValueChanged<List<SubTaskItem>>? onPendingChanged;

  const SubtaskChecklist({
    super.key,
    required this.parentTaskId,
    this.showAddField = true,
    this.showTypeSelector = true,
    this.progressText,
    this.initialSubtasks,
    this.onToggleSubtask,
    this.onPendingChanged,
  });

  @override
  State<SubtaskChecklist> createState() => _SubtaskChecklistState();
}

class _SubtaskChecklistState extends State<SubtaskChecklist> {
  final _addCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _repsCtrl = TextEditingController(text: '10');
  final _setsCtrl = TextEditingController(text: '3');
  TaskType _newSubtaskType = TaskType.generic;
  List<SubTaskItem> _subtasks = [];
  bool _loading = false;

  /// Subtarefas pendentes de persistência (criadas com parentTaskId=0).
  /// Após a tarefa ser criada com um id real, chame [savePendingToRepo].
  List<SubTaskItem> get pendingSubtasks =>
      _subtasks.where((s) => s.id < 0).toList();

  /// Retorna `true` se estivermos rodando dentro de um teste
  /// (`flutter test`). Nesse contexto o Future do Isar (FFI nativo)
  /// não completa no FakeAsync, então devemos evitar chamadas.
  static bool get _inTest =>
      Platform.environment.containsKey('FLUTTER_TEST') ||
      Platform.environment.containsKey('APP_TEST');

  @override
  void initState() {
    super.initState();
    // Se recebeu subtarefas externas (modo card com dados), carrega
    if (!widget.showAddField && widget.initialSubtasks != null) {
      _subtasks = List.from(widget.initialSubtasks!);
    }
    if (widget.showAddField && !_inTest) {
      // Atrasa o carregamento para depois do primeiro frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubtasks());
    }
  }

  @override
  void didUpdateWidget(SubtaskChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentTaskId != widget.parentTaskId) {
      _subtasks = [];
      if (!widget.showAddField && widget.initialSubtasks != null) {
        _subtasks = List.from(widget.initialSubtasks!);
      }
      if (widget.showAddField && !_inTest) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubtasks());
      }
    }
    // Atualiza subtarefas externas se mudaram
    if (!widget.showAddField &&
        widget.initialSubtasks != null &&
        oldWidget.initialSubtasks != widget.initialSubtasks) {
      _subtasks = List.from(widget.initialSubtasks!);
    }
  }

  /// Carrega as subtarefas do banco uma única vez.
  void _loadSubtasks() {
    if (_loading) return;
    _loading = true;
    try {
      final repo = context.read<TaskController>().taskRepo;
      repo.getSubtasks(widget.parentTaskId).then((list) {
        if (mounted) setState(() => _subtasks = list);
        _loading = false;
      }).catchError((_) {
        _loading = false;
      });
    } catch (_) {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    _durationCtrl.dispose();
    _repsCtrl.dispose();
    _setsCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    _addCtrl.clear();

    final isCreation = widget.parentTaskId == 0;

    // Subtarefa temporária (id negativo = não persistida ainda)
    var tempId = DateTime.now().microsecondsSinceEpoch;
    if (tempId > 0) tempId = -tempId; // garante id negativo para pending
    final temp = SubTaskItem()
      ..id = tempId
      ..parentTaskId = widget.parentTaskId
      ..title = text
      ..type = _newSubtaskType
      ..isCompleted = false
      ..order = _subtasks.length
      ..durationSeconds = _newSubtaskType == TaskType.timedExercise
          ? int.tryParse(_durationCtrl.text.trim()) ?? 60
          : null
      ..targetReps = _newSubtaskType == TaskType.repsExercise
          ? int.tryParse(_repsCtrl.text.trim()) ?? 10
          : null
      ..targetSets = _newSubtaskType == TaskType.repsExercise
          ? int.tryParse(_setsCtrl.text.trim()) ?? 3
          : null;

    setState(() => _subtasks = [..._subtasks, temp]);

    if (isCreation) {
      // Modo criação: não persiste ainda. Avisa o pai (TaskForm)
      // para que ele possa salvar as pendentes após criar a tarefa.
      widget.onPendingChanged?.call(_subtasks);
      return;
    }

    try {
      final repo = context.read<TaskController>().taskRepo;
      final newId = await repo
          .addSubtask(temp)
          .timeout(const Duration(seconds: 1))
          .catchError((_) => -1);
      if (newId < 0) throw Exception('add failed');
      // Atualiza o id real retornado pelo banco
      setState(() {
        _subtasks = _subtasks.map((s) {
          if (s.id == tempId) return s..id = newId;
          return s;
        }).toList();
      });
    } catch (_) {
      // Falha ao salvar: remove a entrada temporária
      if (mounted) {
        setState(
            () => _subtasks = _subtasks.where((s) => s.id != tempId).toList());
      }
    }
  }

  /// Persiste todas as subtarefas pendentes (com id negativo) após a
  /// tarefa-pai ter sido criada e seu [realParentTaskId] definido.
  /// Deve ser chamado pelo [TaskForm] após [TaskController.createTask].
  Future<void> savePendingToRepo(int realParentTaskId) async {
    final pending = _subtasks.where((s) => s.id < 0).toList();
    if (pending.isEmpty) return;

    final repo = context.read<TaskController>().taskRepo;
    for (final sub in pending) {
      sub.parentTaskId = realParentTaskId;
      sub.id = DateTime.now().microsecondsSinceEpoch; // id temporário novo
      try {
        final newId = await repo
            .addSubtask(sub)
            .timeout(const Duration(seconds: 2))
            .catchError((_) => -1);
        if (newId > 0 && mounted) {
          setState(() {
            _subtasks = _subtasks.map((s) {
              if (s == sub) return s..id = newId;
              return s;
            }).toList();
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _toggle(int id) async {
    // Otimista: alterna localmente (tanto card quanto formulário)
    setState(() {
      _subtasks = _subtasks.map((s) {
        if (s.id == id) return s..isCompleted = !s.isCompleted;
        return s;
      }).toList();
    });

    // Modo card: só notifica o pai (a persistência fica com ele)
    if (!widget.showAddField) {
      widget.onToggleSubtask?.call(id);
      return;
    }

    try {
      final repo = context.read<TaskController>().taskRepo;
      await repo.toggleSubtask(id).timeout(const Duration(seconds: 1));
    } catch (_) {
      // Reverte em caso de falha
      if (mounted) {
        setState(() {
          _subtasks = _subtasks.map((s) {
            if (s.id == id) return s..isCompleted = !s.isCompleted;
            return s;
          }).toList();
        });
      }
    }
  }

  Future<void> _delete(int id) async {
    // Modo card: sem exclusão
    if (!widget.showAddField) return;

    // Modo criação (id negativo): só remove da memória
    if (id < 0) {
      setState(() => _subtasks = _subtasks.where((s) => s.id != id).toList());
      return;
    }

    // Otimista: remove localmente
    final previous = List<SubTaskItem>.from(_subtasks);
    setState(() => _subtasks = _subtasks.where((s) => s.id != id).toList());

    try {
      final repo = context.read<TaskController>().taskRepo;
      await repo.deleteSubtask(id).timeout(const Duration(seconds: 1));
    } catch (_) {
      // Reverte em caso de falha
      if (mounted) setState(() => _subtasks = previous);
    }
  }

  static IconData _typeIcon(TaskType type) {
    switch (type) {
      case TaskType.generic:
        return Icons.check_circle_outline;
      case TaskType.pomodoroStudy:
        return Icons.school_outlined;
      case TaskType.timedExercise:
        return Icons.timer_outlined;
      case TaskType.repsExercise:
        return Icons.fitness_center_outlined;
    }
  }

  static const _typeLabels = {
    TaskType.generic: 'Geral',
    TaskType.pomodoroStudy: 'Estudo',
    TaskType.timedExercise: 'Tempo',
    TaskType.repsExercise: 'Repetições',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<SubTaskItem> subtasks;
    final int total;
    final int done;

    if (widget.showAddField) {
      // Modo formulário: dados vêm do estado local carregado do banco
      subtasks = _subtasks;
      total = subtasks.length;
      done = subtasks.where((s) => s.isCompleted).length;
    } else if (widget.initialSubtasks != null) {
      // Modo card com dados: exibe as subtarefas com checkboxes
      subtasks = _subtasks;
      total = subtasks.length;
      done = subtasks.where((s) => s.isCompleted).length;
    } else {
      // Modo card sem dados: só o cabeçalho, sem consulta assíncrona.
      subtasks = const [];
      total = 0;
      done = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Cabeçalho ────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.list_alt,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Text(
                widget.progressText ?? 'Passos: $done/$total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: total > 0 && done == total
                      ? Colors.green
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ─── Lista de subtarefas ──────────────────
        if (subtasks.isNotEmpty)
          ...subtasks.map((st) => _buildSubtaskTile(st, theme)),

        // ─── Campo de adicionar (só no formulário) ─
        if (widget.showAddField) ...[
          const Divider(height: 1),
          _buildAddField(theme),
        ],
      ],
    );
  }

  /// Abre o cronômetro para subtarefas do tipo pomodoro ou timedExercise.
  void _openTimerForSubtask(SubTaskItem st) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TimerWidget(
        durationMinutes: st.type == TaskType.pomodoroStudy
            ? AppConstants.defaultPomodoroFocusMinutes
            : 0,
        durationSeconds: st.type == TaskType.timedExercise
            ? (st.durationSeconds ?? AppConstants.defaultTimedExerciseSeconds)
            : null,
        breakDurationMinutes: st.type == TaskType.pomodoroStudy
            ? AppConstants.defaultPomodoroBreakMinutes
            : 0,
        onFinish: () async {
          if (!ctx.mounted) return;
          Navigator.of(ctx).pop();
          if (mounted) _toggle(st.id);
        },
        onCancel: () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }

  /// Abre o contador de repetições para subtarefas do tipo repsExercise.
  void _openRepCounterForSubtask(SubTaskItem st) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => RepCounterWidget(
        targetReps: st.targetReps ?? AppConstants.defaultRepsTarget,
        targetSets: st.targetSets ?? AppConstants.defaultSetsTarget,
        onComplete: () async {
          if (!ctx.mounted) return;
          Navigator.of(ctx).pop();
          if (mounted) _toggle(st.id);
        },
      ),
    );
  }

  Widget _buildSubtaskTile(SubTaskItem st, ThemeData theme) {
    return Dismissible(
      key: ValueKey(st.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
      ),
      onDismissed: (_) => _delete(st.id),
      child: InkWell(
        onTap: () {
          if (st.isCompleted) return;
          switch (st.type) {
            case TaskType.timedExercise:
            case TaskType.pomodoroStudy:
              _openTimerForSubtask(st);
            case TaskType.repsExercise:
              _openRepCounterForSubtask(st);
            case TaskType.generic:
              _toggle(st.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: st.isCompleted,
                  onChanged: (_) => _toggle(st.id),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 2),
              Icon(_typeIcon(st.type),
                  size: 16,
                  color: st.isCompleted
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  st.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration:
                        st.isCompleted ? TextDecoration.lineThrough : null,
                    color: st.isCompleted
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Linha: campo de título + botão add ───
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _addCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Adicionar passo...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  style: theme.textTheme.bodySmall,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _add(),
                ),
              ),
            ],
          ),

          // ─── Seletor de tipo ───
          if (widget.showTypeSelector) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: DropdownButton<TaskType>(
                value: _newSubtaskType,
                isDense: true,
                underline: const SizedBox(),
                items: TaskType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_typeIcon(t), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _typeLabels[t] ?? t.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _newSubtaskType = v);
                },
              ),
            ),
          ],

          // ─── Campos extras por tipo ───
          if (widget.showTypeSelector &&
              _newSubtaskType == TaskType.timedExercise) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duração',
                        hintText: '60',
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    'seg',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (widget.showTypeSelector &&
              _newSubtaskType == TaskType.repsExercise) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Icon(Icons.fitness_center_outlined,
                      size: 14,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _repsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Reps',
                        hintText: '10',
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _setsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Séries',
                        hintText: '3',
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

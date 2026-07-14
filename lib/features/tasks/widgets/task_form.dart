import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_item.dart';
import '../../../data/models/sub_task_item.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/recurrence_parser.dart';
import '../controllers/task_controller.dart';
import 'subtask_checklist.dart';

/// Seletor de regra de recorrência para o formulário de tarefa.
class _RecurrenceSelector extends StatelessWidget {
  final RecurrenceType recurrenceType;
  final Set<int> weekDays;
  final int interval;
  final ValueChanged<RecurrenceType> onTypeChanged;
  final ValueChanged<Set<int>> onWeekDaysChanged;
  final ValueChanged<int> onIntervalChanged;

  const _RecurrenceSelector({
    required this.recurrenceType,
    required this.weekDays,
    required this.interval,
    required this.onTypeChanged,
    required this.onWeekDaysChanged,
    required this.onIntervalChanged,
  });

  static const _weekDayLabels = {
    1: 'Seg',
    2: 'Ter',
    3: 'Qua',
    4: 'Qui',
    5: 'Sex',
    6: 'Sáb',
    7: 'Dom',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repetir',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        DropdownMenu<RecurrenceType>(
          initialSelection: recurrenceType,
          label: const Text('Recorrência'),
          onSelected: (v) {
            if (v != null) onTypeChanged(v);
          },
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: RecurrenceType.none, label: 'Não repete'),
            DropdownMenuEntry(value: RecurrenceType.daily, label: 'Diária'),
            DropdownMenuEntry(value: RecurrenceType.weekly, label: 'Semanal'),
            DropdownMenuEntry(
                value: RecurrenceType.everyNDays, label: 'A cada N dias'),
          ],
        ),
        const SizedBox(height: 8),

        // Se Semanal: mostra os dias da semana
        if (recurrenceType == RecurrenceType.weekly) ...[
          const Text('Dias da semana:', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: _weekDayLabels.entries.map((e) {
              final selected = weekDays.contains(e.key);
              return FilterChip(
                label: Text(e.value, style: const TextStyle(fontSize: 12)),
                selected: selected,
                onSelected: (v) {
                  final updated = Set<int>.from(weekDays);
                  if (v) {
                    updated.add(e.key);
                  } else {
                    updated.remove(e.key);
                  }
                  onWeekDaysChanged(updated);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // Se "a cada N dias": campo de intervalo
        if (recurrenceType == RecurrenceType.everyNDays) ...[
          TextFormField(
            initialValue: interval.toString(),
            decoration: const InputDecoration(
              labelText: 'A cada quantos dias?',
              helperText: 'Ex: 3 = a cada 3 dias',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 1) onIntervalChanged(n);
            },
          ),
        ],
      ],
    );
  }
}

/// Ações possíveis ao editar uma instância de tarefa recorrente.
enum _RecurringEditAction { thisOnly, thisAndFuture }

/// Diálogo que pergunta se a edição deve afetar só esta ocorrência
/// ou esta e as futuras.
class _RecurringEditDialog extends StatelessWidget {
  const _RecurringEditDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar tarefa recorrente'),
      content: const Text(
        'Você está editando uma ocorrência de uma tarefa que se repete. '
        'Deseja aplicar esta alteração apenas a esta ocorrência ou a '
        'esta e às futuras?',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _RecurringEditAction.thisOnly),
          child: const Text('Só esta'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _RecurringEditAction.thisAndFuture),
          child: const Text('Esta e as futuras'),
        ),
      ],
    );
  }
}

/// Modal / tela de criação ou edição de tarefa.
///
/// Os campos exibidos variam conforme [TaskType] selecionado:
///   - generic:          apenas título, descrição, data, horário, pontos
///   - pomodoroStudy:    + duração do foco (padrão 25 min)
///   - timedExercise:    + duração em minutos (padrão 1 min)
///   - repsExercise:     + meta de repetições (padrão 10)
class TaskForm extends StatefulWidget {
  /// Se não-nulo, o formulário opera em modo edição.
  final TaskItem? task;

  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  /// Subtarefas pendentes de persistência (criadas em modo criação,
  /// antes da tarefa existir). Preenchido via [onPendingChanged].
  List<SubTaskItem> _pendingSubtasks = [];

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _setsCtrl;
  late final TextEditingController
      _durationCtrl; // pomodoroStudy (min) / timedExercise (s)
  late final TextEditingController _pointsCtrl;

  TaskType _type = TaskType.generic;
  DateTime? _scheduledDate;
  DateTime? _scheduledTime;
  bool _isNotificationEnabled = true;
  bool _isImportant = false;

  // ─── Recorrência ────────────────────────────────────────────────────

  /// Tipo de recorrência selecionado.
  RecurrenceType _recurrenceType = RecurrenceType.none;

  /// Dias da semana selecionados (1=segunda … 7=domingo), usado
  /// apenas quando [_recurrenceType] é [RecurrenceType.weekly].
  final Set<int> _recurrenceWeekDays = {};

  /// Intervalo em dias para recorrência customizada.
  int _recurrenceInterval = 3;

  /// Se estamos editando uma instância de tarefa recorrente (possui
  /// [parentRecurringId]), precisamos perguntar ao salvar se a alteração
  /// deve afetar "só esta" ou "esta e as futuras".
  bool get _isEditingInstance =>
      widget.task != null && widget.task!.parentRecurringId != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _repsCtrl = TextEditingController(
      text: t?.targetReps?.toString() ??
          AppConstants.defaultRepsTarget.toString(),
    );
    _setsCtrl = TextEditingController(
      text: t?.targetSets?.toString() ??
          AppConstants.defaultSetsTarget.toString(),
    );
    _durationCtrl = TextEditingController(
      text: (t?.type == TaskType.timedExercise
              ? t?.durationSeconds?.toString()
              : t?.durationMinutes?.toString()) ??
          _defaultDuration.toString(),
    );
    _pointsCtrl = TextEditingController(
      text: t?.rewardPoints.toString() ??
          AppConstants.defaultRewardPoints.toString(),
    );

    _type = TaskType.generic;
    _scheduledDate = DateHelpers.today(); // padrão: hoje

    if (t != null) {
      _type = t.type;
      _scheduledDate = t.scheduledDate ?? DateHelpers.today();
      _scheduledTime = t.scheduledTime;
      _isNotificationEnabled = t.isNotificationEnabled;
      _isImportant = t.isImportant;

      // Inicializa recorrência a partir da tarefa-modelo (se for modelo)
      if (t.parentRecurringId == null && t.recurrenceRule != null) {
        final rule = parseRecurrenceRule(t.recurrenceRule);
        _recurrenceType = rule.type;
        _recurrenceWeekDays.addAll(rule.weekDays);
        _recurrenceInterval = rule.intervalDays;
      }
    } else if (_scheduledDate != null && _scheduledTime != null) {
      // Nova tarefa com horário: notificação ligada por padrão
      _isNotificationEnabled = true;
    }
  }

  int get _defaultDuration {
    switch (widget.task?.type ?? _type) {
      case TaskType.timedExercise:
        return AppConstants.defaultTimedExerciseSeconds;
      case TaskType.pomodoroStudy:
        return AppConstants.defaultPomodoroFocusMinutes;
      default:
        return 1;
    }
  }

  /// Aplica a regra de recorrência selecionada nos campos da [task].
  /// Usado para tarefas novas ou edição de modelo/avulsa.
  void _applyRecurrenceToTask(TaskItem task) {
    if (_recurrenceType == RecurrenceType.none) {
      task.recurrenceRule = null;
      return;
    }
    final rule = RecurrenceRule(
      type: _recurrenceType,
      weekDays: _recurrenceWeekDays.toList()..sort(),
      intervalDays: _recurrenceInterval,
    );
    task.recurrenceRule = serializeRecurrenceRule(rule);
  }

  /// Ao editar uma instância de tarefa recorrente, pergunta ao usuário
  /// se deseja aplicar a alteração "só nesta" ou "nesta e nas futuras".
  Future<void> _saveRecurringInstance(TaskItem task) async {
    final action = await showDialog<_RecurringEditAction>(
      context: context,
      builder: (ctx) => _RecurringEditDialog(),
    );
    if (action == null || !mounted) return;

    final controller = context.read<TaskController>();

    if (action == _RecurringEditAction.thisOnly) {
      // Salva apenas esta instância (já populada com os dados do form)
      await controller.updateTask(task);
    } else {
      // "Esta e as futuras": primeiro salva a instância, depois
      // atualiza a tarefa-modelo com a regra/título/dados novos,
      // e depois regenera as instâncias futuras a partir do modelo.
      final repo = controller.taskRepo;

      // 1. Salva os dados editados na instância atual
      await controller.updateTask(task);

      // 2. Carrega a tarefa-modelo
      final model = await repo.getById(task.parentRecurringId!);
      if (model != null) {
        // Aplica os novos dados ao modelo
        model.title = task.title;
        model.description = task.description;
        model.type = task.type;
        model.rewardPoints = task.rewardPoints;
        model.durationMinutes = task.durationMinutes;
        model.durationSeconds = task.durationSeconds;
        model.targetReps = task.targetReps;
        model.targetSets = task.targetSets;
        model.scheduledDate = task.scheduledDate;
        model.scheduledTime = task.scheduledTime;
        model.isNotificationEnabled = task.isNotificationEnabled;
        model.isImportant = task.isImportant;

        // Aplica a regra de recorrência editada
        _applyRecurrenceToTask(model);

        await controller.updateTask(model);

        // 3. Regenera instâncias futuras
        await repo.ensureUpcomingInstances();
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _repsCtrl.dispose();
    _setsCtrl.dispose();
    _durationCtrl.dispose();
    _pointsCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime != null
          ? TimeOfDay.fromDateTime(_scheduledTime!)
          : now,
    );
    if (picked != null) {
      setState(() =>
          _scheduledTime = DateTime(2000, 1, 1, picked.hour, picked.minute));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.task != null;
    final task = isEditing ? widget.task! : TaskItem();

    task.title = _titleCtrl.text.trim();
    task.description =
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();
    task.type = _type;
    task.scheduledDate = _scheduledDate != null
        ? DateHelpers.normalizeToDay(_scheduledDate!)
        : null;
    task.scheduledTime = _scheduledTime;

    task.rewardPoints =
        int.tryParse(_pointsCtrl.text) ?? AppConstants.defaultRewardPoints;
    task.isNotificationEnabled =
        _scheduledDate != null && _scheduledTime != null
            ? _isNotificationEnabled
            : false;
    task.isImportant = _isImportant && task.isNotificationEnabled;

    // Limpa campos irrelevantes para o tipo antes de salvar
    switch (_type) {
      case TaskType.generic:
        task.durationMinutes = null;
        task.durationSeconds = null;
        task.targetReps = null;
        task.targetSets = null;
      case TaskType.pomodoroStudy:
        task.durationMinutes =
            int.tryParse(_durationCtrl.text) ?? _defaultDuration;
        task.durationSeconds = null;
        task.targetReps = null;
        task.targetSets = null;
      case TaskType.timedExercise:
        task.durationMinutes = null;
        task.durationSeconds =
            int.tryParse(_durationCtrl.text) ?? _defaultDuration;
        task.targetReps = null;
        task.targetSets = null;
      case TaskType.repsExercise:
        task.durationMinutes = null;
        task.durationSeconds = null;
        task.targetReps =
            int.tryParse(_repsCtrl.text) ?? AppConstants.defaultRepsTarget;
        task.targetSets =
            int.tryParse(_setsCtrl.text) ?? AppConstants.defaultSetsTarget;
    }

    // ─── Lida com recorrência ──────────────────────────────────────
    if (_isEditingInstance) {
      // Editando uma instância de tarefa recorrente
      await _saveRecurringInstance(task);
    } else {
      // Nova tarefa ou edição de modelo / avulsa
      _applyRecurrenceToTask(task);

      try {
        if (isEditing) {
          await context.read<TaskController>().updateTask(task);

          // Nudge de adiamento repetido (Módulo 8)
          if (task.postponeCount >= 3 && mounted) {
            final shouldOpenSubtasks = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Tarefa adiada várias vezes'),
                content: Text(
                  'Esta tarefa já foi adiada ${task.postponeCount} vezes. '
                  'Que tal quebrá-la em passos menores usando subtarefas? '
                  'Isso pode ajudar a torná-la menos intimidante.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Apenas salvar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Quebrar em passos'),
                  ),
                ],
              ),
            );
            if (shouldOpenSubtasks == true && mounted) {
              // Mantém o formulário aberto e rola até o SubtaskChecklist
              // para o usuário adicionar passos imediatamente.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
              return;
            }
          }
        } else {
          await context.read<TaskController>().createTask(
                task,
                subtasks: _pendingSubtasks.isNotEmpty ? _pendingSubtasks : null,
              );
          // Atualiza o cache para que o card reflita as subtarefas
          if (_pendingSubtasks.isNotEmpty) {
            unawaited(context
                .read<TaskController>()
                .refreshSubtaskCacheForTask(task.id));
          }
        }
      } catch (e) {
        if (!mounted) return;
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
        actions: [
          TextButton(
            onPressed: () => _submit(),
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Título ─────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'O que você precisa fazer?',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
            ),
            const SizedBox(height: 12),

            // ─── Descrição ───────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // ─── Tipo ────────────────────────────────────────
            DropdownMenu<TaskType>(
              initialSelection: _type,
              label: const Text('Tipo'),
              onSelected: (v) {
                if (v == null) return;
                setState(() => _type = v);
                // Atualiza duração sugerida ao trocar de tipo
                if (v == TaskType.timedExercise) {
                  _durationCtrl.text =
                      AppConstants.defaultTimedExerciseSeconds.toString();
                } else if (v == TaskType.pomodoroStudy) {
                  _durationCtrl.text =
                      AppConstants.defaultPomodoroFocusMinutes.toString();
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: TaskType.generic,
                  label: 'Genérica',
                ),
                DropdownMenuEntry(
                  value: TaskType.pomodoroStudy,
                  label: 'Estudo (Pomodoro)',
                ),
                DropdownMenuEntry(
                  value: TaskType.timedExercise,
                  label: 'Exercício por tempo',
                ),
                DropdownMenuEntry(
                  value: TaskType.repsExercise,
                  label: 'Exercício por repetições',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Campos específicos por tipo ────────────────
            if (_type == TaskType.pomodoroStudy ||
                _type == TaskType.timedExercise) ...[
              TextFormField(
                controller: _durationCtrl,
                decoration: InputDecoration(
                  labelText: _type == TaskType.pomodoroStudy
                      ? 'Duração do foco (minutos)'
                      : 'Duração (segundos)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Valor mínimo: 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            if (_type == TaskType.repsExercise) ...[
              TextFormField(
                controller: _repsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Repetições por série',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Valor mínimo: 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _setsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de séries',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Valor mínimo: 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            // ─── Data ───────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _scheduledDate != null
                    ? DateFormat('dd/MM/yyyy').format(_scheduledDate!)
                    : 'Nenhuma data',
              ),
              subtitle: const Text('Atribuir data'),
              onTap: _pickDate,
              trailing: _scheduledDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _scheduledDate = null),
                    )
                  : null,
            ),

            // ─── Horário ─────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                _scheduledTime != null
                    ? DateFormat('HH:mm').format(_scheduledTime!)
                    : 'Nenhum horário',
              ),
              subtitle: const Text('Atribuir horário'),
              onTap: _pickTime,
              trailing: _scheduledTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _scheduledTime = null),
                    )
                  : null,
            ),

            // ─── Pontos de recompensa ───────────────────────
            TextFormField(
              controller: _pointsCtrl,
              decoration: const InputDecoration(
                labelText: 'Pontos de recompensa',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final p = int.tryParse(v ?? '');
                if (p == null || p < 1) return 'Mínimo: 1';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ─── Notificar ────────────────────────────────────
            // Só faz sentido se data e horário estiverem preenchidos
            if (_scheduledDate != null && _scheduledTime != null)
              SwitchListTile(
                title: const Text('Notificar'),
                subtitle: const Text(
                    'Lembrar no horário agendado (notificação ou alarme)'),
                value: _isNotificationEnabled,
                onChanged: (v) => setState(() {
                  _isNotificationEnabled = v;
                  // Se desligar notificação, "Importante" perde efeito
                  if (!v) _isImportant = false;
                }),
              ),

            // ─── Importante (alarme insistente) ──────────────
            SwitchListTile(
              title: const Text('Importante (alarme com som)'),
              subtitle: const Text(
                  'Toca alarme insistente em vez de notificação simples'),
              value: _isImportant,
              onChanged: (_isNotificationEnabled &&
                      _scheduledDate != null &&
                      _scheduledTime != null)
                  ? (v) => setState(() => _isImportant = v)
                  : null,
            ),
            const Divider(height: 24),

            // ─── Recorrência ──────────────────────────────────
            // Só permite configurar recorrência se NÃO estamos editando
            // uma instância (senão a regra é lida da tarefa-modelo).
            if (!_isEditingInstance) ...[
              _RecurrenceSelector(
                recurrenceType: _recurrenceType,
                weekDays: _recurrenceWeekDays,
                interval: _recurrenceInterval,
                onTypeChanged: (t) => setState(() => _recurrenceType = t),
                onWeekDaysChanged: (days) => setState(() => _recurrenceWeekDays
                  ..clear()
                  ..addAll(days)),
                onIntervalChanged: (v) =>
                    setState(() => _recurrenceInterval = v),
              ),
            ] else ...[
              // Mostra um badge informativo para instâncias
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Tarefa recorrente'),
                subtitle:
                    const Text('Editar esta ocorrência não afeta as outras'),
              ),
            ],
            const Divider(height: 24),

            // ─── Subtarefas (checklist) ───────────────────────
            SubtaskChecklist(
              // Em criação (task == null) usa 0 como placeholder;
              // após criar a task, persistimos as pendentes com o id real.
              parentTaskId: widget.task?.id ?? 0,
              showAddField: true,
              showTypeSelector: true,
              onPendingChanged: (list) => _pendingSubtasks = list,
            ),
          ],
        ),
      ),
    );
  }
}

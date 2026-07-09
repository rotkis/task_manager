import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_item.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_helpers.dart';
import '../controllers/task_controller.dart';

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

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _repsCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _pointsCtrl;

  TaskType _type = TaskType.generic;
  DateTime? _scheduledDate;
  DateTime? _scheduledTime;
  bool _isImportant = false;

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
    _durationCtrl = TextEditingController(
      text: t?.durationMinutes?.toString() ?? _defaultDuration.toString(),
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
      _isImportant = t.isImportant;
    }
  }

  int get _defaultDuration {
    switch (widget.task?.type ?? _type) {
      case TaskType.timedExercise:
        return AppConstants.defaultTimedExerciseMinutes;
      case TaskType.pomodoroStudy:
        return AppConstants.defaultPomodoroFocusMinutes;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _repsCtrl.dispose();
    _durationCtrl.dispose();
    _pointsCtrl.dispose();
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
    task.isImportant = _isImportant;

    // Limpa campos irrelevantes para o tipo antes de salvar
    switch (_type) {
      case TaskType.generic:
        task.durationMinutes = null;
        task.targetReps = null;
      case TaskType.pomodoroStudy:
      case TaskType.timedExercise:
        task.durationMinutes =
            int.tryParse(_durationCtrl.text) ?? _defaultDuration;
        task.targetReps = null;
      case TaskType.repsExercise:
        task.durationMinutes = null;
        task.targetReps =
            int.tryParse(_repsCtrl.text) ?? AppConstants.defaultRepsTarget;
    }

    if (isEditing) {
      await context.read<TaskController>().updateTask(task);
    } else {
      await context.read<TaskController>().createTask(task);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
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
                      AppConstants.defaultTimedExerciseMinutes.toString();
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
                      : 'Duração (minutos)',
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
                  labelText: 'Meta de repetições',
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

            // ─── Importante (alarme insistente) ──────────────
            SwitchListTile(
              title: const Text('Importante (alarme com som)'),
              subtitle: const Text(
                  'Toca alarme insistente em vez de notificação simples'),
              value: _isImportant,
              onChanged: (v) => setState(() => _isImportant = v),
            ),
          ],
        ),
      ),
    );
  }
}

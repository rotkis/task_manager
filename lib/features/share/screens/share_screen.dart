import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../tasks/controllers/task_controller.dart';
import '../controllers/share_controller.dart';
import '../../../data/models/task_item.dart';

/// Tela de compartilhamento com duas abas:
/// - **Compartilhar**: seleciona tarefas e gera código/QR
/// - **Importar**: cola código, visualiza prévia e confirma importação
class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ShareController>();
    final tasks = context.watch<TaskController>().allTasks;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Compartilhar', icon: Icon(Icons.upload)),
            Tab(text: 'Importar', icon: Icon(Icons.download)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ExportTab(tasks: tasks, controller: controller),
              _ImportTab(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Aba Compartilhar ───────────────────────────────────────────────

class _ExportTab extends StatelessWidget {
  final List<TaskItem> tasks;
  final ShareController controller;

  const _ExportTab({
    required this.tasks,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = controller.generatedCode;

    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma tarefa para compartilhar.\nCrie algumas tarefas primeiro.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Lista de tarefas selecionáveis
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final selected = controller.selectedIds.contains(task.id);
              return CheckboxListTile(
                value: selected,
                title: Text(task.title),
                subtitle: Text(_taskSubtitle(task)),
                onChanged: (_) => controller.toggleSelection(task.id),
              );
            },
          ),
        ),

        // Ações
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (code != null) ...[
                  // Código gerado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      code,
                      style: const TextStyle(fontFamily: 'monospace'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Copiar'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código copiado!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Limpar'),
                          onPressed: controller.clearSelection,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.qr_code),
                    label: Text(
                        code != null ? 'Regenerar Código' : 'Gerar Código'),
                    onPressed: controller.selectedIds.isEmpty
                        ? null
                        : () => controller.generateCode(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _taskSubtitle(TaskItem task) {
    final parts = <String>[
      task.scheduledDate != null
          ? '${task.scheduledDate!.day}/${task.scheduledDate!.month}'
          : 'Sem data',
    ];
    if (task.scheduledTime != null) {
      parts.add(
        '${task.scheduledTime!.hour.toString().padLeft(2, '0')}:${task.scheduledTime!.minute.toString().padLeft(2, '0')}',
      );
    }
    parts.add('${task.rewardPoints} pts');
    return parts.join(' · ');
  }
}

// ─── Aba Importar ───────────────────────────────────────────────────

class _ImportTab extends StatefulWidget {
  final ShareController controller;
  const _ImportTab({required this.controller});

  @override
  State<_ImportTab> createState() => _ImportTabState();
}

class _ImportTabState extends State<_ImportTab> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.controller.importStatus;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de código
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Código de compartilhamento',
              hintText: 'Cole o código aqui...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final text = data?.text;
                  if (text != null) {
                    _codeController.text = text;
                  }
                },
              ),
            ),
            maxLines: 3,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Botão visualizar
          if (status == ImportStatus.idle || status == ImportStatus.error)
            FilledButton.icon(
              icon: const Icon(Icons.preview),
              label: const Text('Visualizar'),
              onPressed: _codeController.text.trim().isEmpty
                  ? null
                  : () => widget.controller.previewCode(
                        _codeController.text.trim(),
                      ),
            ),

          // Erro
          if (status == ImportStatus.error &&
              widget.controller.importError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                widget.controller.importError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          // Prévia
          if (status == ImportStatus.preview &&
              widget.controller.previewTasks != null) ...[
            const SizedBox(height: 16),
            Text(
              'Tarefas encontradas:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.controller.previewTasks!.length,
                itemBuilder: (context, index) {
                  final task = widget.controller.previewTasks![index];
                  return ListTile(
                    leading: Icon(_taskIcon(task.type)),
                    title: Text(task.title),
                    subtitle: Text(_previewSubtitle(task)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.controller.resetImport();
                      _codeController.clear();
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Importar'),
                    onPressed: () => widget.controller.confirmImport(),
                  ),
                ),
              ],
            ),
          ],

          // Sucesso
          if (status == ImportStatus.success) ...[
            const SizedBox(height: 24),
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.controller.importedCount} tarefa(s) importada(s) com sucesso!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                widget.controller.resetImport();
                _codeController.clear();
              },
              child: const Text('Importar outro código'),
            ),
          ],
        ],
      ),
    );
  }

  IconData _taskIcon(TaskType type) {
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

  String _previewSubtitle(TaskItem task) {
    final parts = <String>[
      task.scheduledDate != null
          ? '${task.scheduledDate!.day}/${task.scheduledDate!.month}'
          : 'Sem data',
    ];
    if (task.durationMinutes != null) {
      parts.add('${task.durationMinutes} min');
    }
    if (task.targetReps != null) {
      parts.add('${task.targetReps} reps');
    }
    parts.add('${task.rewardPoints} pts');
    return parts.join(' · ');
  }
}

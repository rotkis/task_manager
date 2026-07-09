import 'package:flutter/foundation.dart';

import '../../../data/models/task_item.dart';
import '../../../data/repositories/share_repository.dart';

/// Estado da operação de importação.
enum ImportStatus { idle, preview, success, error }

/// Controlador da tela de compartilhamento.
///
/// Gerencia a seleção de tarefas para exportar e o fluxo de importação.
class ShareController extends ChangeNotifier {
  final ShareRepository _repository;

  ShareController({required ShareRepository repository})
      : _repository = repository;

  // ─── Exportar ──────────────────────────────────────────────────────

  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);

  String? _generatedCode;
  String? get generatedCode => _generatedCode;

  void toggleSelection(int taskId) {
    if (_selectedIds.contains(taskId)) {
      _selectedIds.remove(taskId);
    } else {
      _selectedIds.add(taskId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _generatedCode = null;
    notifyListeners();
  }

  Future<void> generateCode() async {
    // Sempre gera uma nova string
    _generatedCode = await _repository.exportSelected(_selectedIds);
    notifyListeners();
  }

  // ─── Importar ──────────────────────────────────────────────────────

  ImportStatus _importStatus = ImportStatus.idle;
  ImportStatus get importStatus => _importStatus;

  List<TaskItem>? _previewTasks;
  List<TaskItem>? get previewTasks => _previewTasks;

  int _importedCount = 0;
  int get importedCount => _importedCount;

  String? _importError;
  String? get importError => _importError;

  /// Mostra a prévia das tarefas decodificadas de um [code] sem
  /// ainda salvá-las no banco.
  void previewCode(String code) {
    // Usamos decodeTasks do repositório para mostrar a prévia
    final tasks = _repository.previewFromCode(code);
    if (tasks.isEmpty) {
      _importStatus = ImportStatus.error;
      _importError = 'Código inválido ou vazio.';
      _previewTasks = null;
    } else {
      _importStatus = ImportStatus.preview;
      _previewTasks = tasks;
      _importError = null;
    }
    notifyListeners();
  }

  /// Confirma a importação das tarefas previamente pré-visualizadas.
  Future<void> confirmImport() async {
    if (_previewTasks == null || _previewTasks!.isEmpty) {
      _importStatus = ImportStatus.error;
      _importError = 'Nada para importar.';
      notifyListeners();
      return;
    }

    try {
      _importedCount = await _repository.importTasks(_previewTasks!);
      _importStatus = ImportStatus.success;
      _previewTasks = null;
    } catch (e) {
      _importStatus = ImportStatus.error;
      _importError = 'Erro ao importar: $e';
    }
    notifyListeners();
  }

  /// Reseta o estado de importação para idle.
  void resetImport() {
    _importStatus = ImportStatus.idle;
    _previewTasks = null;
    _importError = null;
    notifyListeners();
  }
}

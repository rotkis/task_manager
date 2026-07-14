import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task_item.dart';
import '../models/progress_log.dart';
import '../models/sub_task_item.dart';

/// Ponto único de acesso ao banco Isar. Chame [IsarService.open]
/// uma vez no main() antes de rodar o app.
class IsarService {
  IsarService._();
  static Isar? _instance;

  /// Instância atual do Isar. Lança exceção se não foi inicializado.
  static Isar get instance => _instance!;

  /// Abre o banco Isar no diretório de documentos do dispositivo.
  static Future<void> open() async {
    if (_instance != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [TaskItemSchema, ProgressLogSchema, SubTaskItemSchema],
      directory: dir.path,
    );
  }

  /// Define uma instância de Isar para uso em testes.
  /// Deve ser chamado antes de qualquer repository.
  static void setTestInstance(Isar isar) {
    _instance = isar;
  }

  /// Reseta a instância (útil entre testes).
  static void reset() {
    _instance = null;
  }
}

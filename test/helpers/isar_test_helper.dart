import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:task_manager/data/models/task_item.dart';
import 'package:task_manager/data/models/progress_log.dart';
import 'package:task_manager/data/models/sub_task_item.dart';
import 'package:task_manager/data/isar/isar_service.dart';

/// Abre uma instância Isar temporária (em disco, diretório system temp)
/// e a registra no [IsarService] para uso nos testes.
///
/// Chame [close] no tearDown para fechar e limpar.
class IsarTestHelper {
  Isar? _isar;
  Directory? _dir;

  Isar get isar => _isar!;

  Future<void> open() async {
    _dir = await Directory.systemTemp.createTemp('isar_test_');
    _isar = await Isar.open(
      [TaskItemSchema, ProgressLogSchema, SubTaskItemSchema],
      directory: _dir!.path,
    );
    IsarService.setTestInstance(_isar!);
  }

  Future<void> close() async {
    await _isar?.close();
    if (_dir != null && await _dir!.exists()) {
      await _dir!.delete(recursive: true);
    }
    IsarService.reset();
  }
}

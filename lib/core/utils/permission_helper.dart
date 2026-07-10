import 'package:flutter/services.dart';

/// Utilitário para verificar e solicitar permissões específicas do Android
/// que não são cobertas pelo [`flutter_local_notifications`] nem pelo pacote
/// `alarm`.
///
/// Usa o MethodChannel `task_manager/permissions` definido em
/// `MainActivity.kt`.
class PermissionHelper {
  static const _channel = MethodChannel('task_manager/permissions');

  // ─── Notificação (Android 13+) ────────────────────────────────────

  /// Verifica se a permissão `POST_NOTIFICATIONS` está concedida.
  static Future<bool> checkNotificationPermission() async {
    final result =
        await _channel.invokeMethod<bool>('checkNotificationPermission');
    return result ?? false;
  }

  /// Abre a tela de configurações do app para o usuário ativar
  /// notificações manualmente.
  static Future<void> openAppSettings() async {
    await _channel.invokeMethod('openAppSettings');
  }

  // ─── Alarme exato (Android 12+) ────────────────────────────────────

  /// Verifica se o app pode agendar alarmes exatos.
  static Future<bool> checkExactAlarmPermission() async {
    final result =
        await _channel.invokeMethod<bool>('checkExactAlarmPermission');
    return result ?? false;
  }

  /// Abre a tela do sistema para conceder permissão de alarme exato.
  static Future<void> openExactAlarmSettings() async {
    await _channel.invokeMethod('openExactAlarmSettings');
  }

  // ─── Otimização de bateria ─────────────────────────────────────────

  /// Verifica se o app está isento da otimização de bateria.
  static Future<bool> isBatteryOptimizationIgnored() async {
    final result =
        await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
    return result ?? false;
  }

  /// Abre a tela do sistema para solicitar isenção da otimização de
  /// bateria.
  static Future<void> requestIgnoreBatteryOptimization() async {
    await _channel.invokeMethod('requestIgnoreBatteryOptimization');
  }
}

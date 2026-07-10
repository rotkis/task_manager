import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/utils/permission_helper.dart';
import '../notification_service.dart';

/// Bottom sheet com o estado das permissões de notificação e alarme, botões
/// para ativar cada uma, botão de teste e aviso específico para MIUI.
///
/// Uso:
/// ```dart
/// NotificationSettingsSheet.show(context);
/// ```
class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  /// Abre a bottom sheet de configurações de notificação.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  final _notifPlugin = FlutterLocalNotificationsPlugin();
  final _notificationService = NotificationService();
  bool _loading = true;
  bool _schedulingTest = false;

  bool _notifGranted = false;
  bool _exactAlarmGranted = false;
  bool _batteryOk = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final notif = await PermissionHelper.checkNotificationPermission();
      final alarm = await PermissionHelper.checkExactAlarmPermission();
      final battery = await PermissionHelper.isBatteryOptimizationIgnored();

      debugPrint('''
━━━ [NotificationSettingsSheet] _load() ━━━
notifGranted:       $notif
exactAlarmGranted:  $alarm
batteryOk:          $battery
OBS: se exactAlarmGranted=true mas o app NÃO aparece em
     Configurações > Apps > Acesso especial > Alarmes e lembretes,
     então a API canScheduleExactAlarms() está mentindo no MIUI.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''');

      if (!mounted) return;
      setState(() {
        _notifGranted = notif;
        _exactAlarmGranted = alarm;
        _batteryOk = battery;
        _loading = false;
      });
    } catch (e) {
      debugPrint('━━━ [NotificationSettingsSheet] _load() error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ─── Testar agendamento ───────────────────────────────────────────

  Future<void> _scheduleDebugTest() async {
    setState(() => _schedulingTest = true);
    try {
      await _notificationService.scheduleDebugTest(seconds: 30);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teste agendado! Aguarde 30 segundos com o app fechado.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _schedulingTest = false);
    }
  }

  // ─── Testar notificação ────────────────────────────────────────────

  Future<void> _testNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled tasks',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    // Usa um id fixo para o teste (0)
    await _notifPlugin.show(
        0, '🔔 Task Manager', 'Notificação de teste!', details);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificação de teste enviada!')),
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final okColor = theme.colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ListView(
            controller: scrollController,
            children: [
              // Alça de arrasto
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Notificações e alarmes', style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Verifique as permissões abaixo para garantir que o app '
                'consegue te lembrar das tarefas mesmo em segundo plano.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),

              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // ─── Notificações ────────────────────────────────
                _PermissionTile(
                  icon: Icons.notifications_active,
                  title: 'Notificações',
                  subtitle: _notifGranted
                      ? 'Permissão concedida'
                      : 'Toque em "Ativar" e habilite "Permitir notificações"',
                  ok: _notifGranted,
                  okColor: okColor,
                  errorColor: errorColor,
                  actionLabel: _notifGranted ? null : 'Ativar',
                  onAction: _notifGranted
                      ? null
                      : () async {
                          await PermissionHelper.openAppSettings();
                          // Após voltar, recarrega o status
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          _load();
                        },
                ),
                const SizedBox(height: 8),

                // ─── Alarme exato ────────────────────────────────
                _PermissionTile(
                  icon: Icons.alarm,
                  title: 'Alarme exato',
                  subtitle: _exactAlarmGranted
                      ? 'Permissão concedida'
                      : 'Necessário para notificações no horário exato',
                  ok: _exactAlarmGranted,
                  okColor: okColor,
                  errorColor: errorColor,
                  actionLabel: _exactAlarmGranted ? null : 'Ativar',
                  onAction: _exactAlarmGranted
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok =
                              await PermissionHelper.openExactAlarmSettings();
                          if (!mounted) return;
                          if (!ok) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Não foi possível abrir as configurações. '
                                  'Vá manualmente em: Configurações > Apps > '
                                  'Acesso especial > Alarmes e lembretes',
                                ),
                              ),
                            );
                          }
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          _load();
                        },
                ),
                const SizedBox(height: 8),

                // ─── Bateria ─────────────────────────────────────
                _PermissionTile(
                  icon: Icons.battery_std,
                  title: 'Otimização de bateria',
                  subtitle: _batteryOk
                      ? 'App liberado para rodar em segundo plano'
                      : 'Toque em "Ativar" e selecione "Sem restrições"',
                  ok: _batteryOk,
                  okColor: okColor,
                  errorColor: errorColor,
                  actionLabel: _batteryOk ? null : 'Ativar',
                  onAction: _batteryOk
                      ? null
                      : () async {
                          await PermissionHelper
                              .requestIgnoreBatteryOptimization();
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                          _load();
                        },
                ),
              ],
              const SizedBox(height: 20),

              // ─── Botões Testar ──────────────────────────────────
              FilledButton.icon(
                icon: const Icon(Icons.flash_on),
                label: const Text('Testar agora (imediato)'),
                onPressed: _testNotification,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: _schedulingTest
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.schedule),
                label: const Text('Agendar teste em 30s'),
                onPressed: _schedulingTest ? null : _scheduleDebugTest,
              ),
              const SizedBox(height: 24),

              // ─── Aviso MIUI ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone_android, size: 18, color: errorColor),
                        const SizedBox(width: 6),
                        Text('Dispositivos Xiaomi (MIUI)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: errorColor,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Se você usa um Xiaomi, Redmi ou POCO, mesmo com as '
                      'permissões acima ativadas o sistema pode bloquear '
                      'notificações em segundo plano.\n\n'
                      'Para garantir o funcionamento:\n'
                      '1. Configurações > Apps > Acesso especial > '
                      'Alarmes e lembretes > ativar para Task Manager\n'
                      '2. Configurações > Apps > Gerenciar apps > '
                      'Task Manager > Bateria > "Sem restrições"\n'
                      '3. Configurações > Apps > Permissões de início '
                      'automático > ativar para Task Manager\n'
                      '4. Configurações > Notificações > Task Manager > '
                      'ativar "Permitir notificações" e "Pop-up"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tile de permissão ──────────────────────────────────────────────

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool ok;
  final Color okColor;
  final Color errorColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ok,
    required this.okColor,
    required this.errorColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: ok ? okColor : errorColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ok
                          ? okColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

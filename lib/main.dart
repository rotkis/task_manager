import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/utils/permission_helper.dart';
import 'core/utils/backup_codec.dart';
import 'data/isar/isar_service.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'features/notifications/alarm_service.dart';
import 'features/notifications/notification_service.dart';
import 'features/notifications/weekly_summary_service.dart';
import 'features/notifications/widgets/notification_settings_sheet.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/tasks/screens/tasks_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await IsarService.open();

  // ─── Timezone ───────────────────────────────────────────────────
  // O tz.initializeTimeZones() sempre reseta tz.local para UTC.
  // Precisamos obter o timezone real do dispositivo e setá-lo.
  tz_data.initializeTimeZones();
  try {
    final deviceTz = await PermissionHelper.getDeviceTimezone();
    if (deviceTz != null && deviceTz.isNotEmpty) {
      tz.setLocalLocation(tz.getLocation(deviceTz));
      debugPrint('━━━ [main] tz.local set to: $deviceTz');
    }
  } catch (e) {
    debugPrint('━━━ [main] timezone detection failed: $e (using UTC)');
    // Fallback: tz.local permanece UTC (default do initializeTimeZones)
  }

  // Inicializa serviços de notificação e alarme
  final notificationService = NotificationService();
  final alarmService = AlarmService();
  await notificationService.init();
  await alarmService.init();

  // Agenda o resumo semanal (domingo 20h)
  final weeklySummary = WeeklySummaryService(
    progressRepository: ProgressRepository(),
    notificationService: notificationService,
  );
  await weeklySummary.scheduleNext();

  runApp(TaskManagerApp(
    notificationService: notificationService,
    alarmService: alarmService,
  ));
}

class TaskManagerApp extends StatefulWidget {
  final NotificationService notificationService;
  final AlarmService alarmService;

  const TaskManagerApp({
    super.key,
    required this.notificationService,
    required this.alarmService,
  });

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskController(
            notificationService: widget.notificationService,
            alarmService: widget.alarmService,
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: HomeShell(
          onToggleTheme: () {
            setState(() {
              _themeMode = _themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            });
          },
        ),
      ),
    );
  }
}

/// Casca com navegação por abas: Tarefas, Cronograma/Calendário, Evolução.
class HomeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeShell({super.key, required this.onToggleTheme});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _backupRepo = BackupRepository();

  static const _titles = [
    'Tarefas',
    'Cronograma',
    'Evolução',
  ];

  static const _pages = <Widget>[
    TasksScreen(),
    CalendarScreen(),
    StatsScreen(),
  ];

  /// Exporta todos os dados para um arquivo JSON e abre a folha de
  /// compartilhamento nativa.
  Future<void> _exportBackup() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Mostra loading
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final json = await _backupRepo.exportAll();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'task_manager_backup_${DateTime.now().toIso8601String().split('T').first}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(json);

      if (!mounted) return;
      // Fecha o loading
      Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Backup Task Manager',
      );
    } catch (e) {
      if (!mounted) return;
      // Fecha o loading se ainda estiver aberto
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  /// Abre o seletor de arquivos para importar um backup.
  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;
      if (!mounted) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      final file = File(filePath);
      final json = await file.readAsString();

      // Valida o backup antes de prosseguir
      // (backup_codec.decodeBackup já valida internamente)
      final testParse = decodeBackup(json);
      if (testParse == null) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Arquivo de backup inválido.')),
        );
        return;
      }

      if (!mounted) return;
      // Pergunta: mesclar ou substituir?
      final merge = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Importar backup'),
          content: Text(
            'Foram encontradas ${testParse.tasks.length} tarefa(s), '
            '${testParse.subtasks.length} subtarefa(s) e '
            '${testParse.progressLogs.length} registro(s) de progresso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Mesclar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Substituir'),
            ),
          ],
        ),
      );

      if (merge == null || !mounted) return;

      // Mostra loading
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final importedTasks = await _backupRepo.importAll(json, merge: merge);

      // Agenda notificação/alarme para tarefas importadas que tenham
      // scheduledDate + scheduledTime e notification ativa
      if (!mounted) return;
      Navigator.of(context).pop(); // Fecha loading

      try {
        final taskController = context.read<TaskController>();
        await taskController.scheduleNotificationsForTasks(importedTasks);
      } catch (_) {
        // Falha ao agendar notificações não deve impedir a importação
      }

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            merge
                ? 'Backup importado com sucesso (mesclado)!'
                : 'Backup importado com sucesso (substituído)!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportBackup();
                case 'import':
                  _importBackup();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.file_upload_outlined),
                  title: Text('Exportar backup'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text('Importar backup'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificações',
            onPressed: () => NotificationSettingsSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => TasksScreen.openForm(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline), label: 'Tarefas'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), label: 'Cronograma'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Evolução'),
        ],
      ),
    );
  }
}

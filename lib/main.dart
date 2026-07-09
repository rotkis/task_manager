import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/isar/isar_service.dart';
import 'data/repositories/share_repository.dart';
import 'features/notifications/alarm_service.dart';
import 'features/notifications/notification_service.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/share/controllers/share_controller.dart';
import 'features/share/screens/share_screen.dart';
import 'features/stats/screens/stats_screen.dart';
import 'features/tasks/controllers/task_controller.dart';
import 'features/tasks/screens/tasks_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open();

  // Inicializa serviços de notificação e alarme
  final notificationService = NotificationService();
  final alarmService = AlarmService();
  await notificationService.init();
  await alarmService.init();

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
        ChangeNotifierProvider(
          create: (_) => ShareController(
            repository: ShareRepository(),
          ),
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

/// Casca com navegação por abas: Tarefas, Cronograma/Calendário, Evolução,
/// Compartilhar.
class HomeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeShell({super.key, required this.onToggleTheme});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Tarefas',
    'Cronograma',
    'Evolução',
    'Compartilhar',
  ];

  static const _pages = <Widget>[
    TasksScreen(),
    CalendarScreen(),
    StatsScreen(),
    ShareScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
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
          NavigationDestination(
              icon: Icon(Icons.share_outlined), label: 'Compartilhar'),
        ],
      ),
    );
  }
}

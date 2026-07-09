import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/date_helpers.dart';
import '../../../data/models/task_item.dart';
import '../../tasks/controllers/task_controller.dart';
import '../controllers/calendar_controller.dart';
import '../widgets/schedule_list.dart';

/// Tela de calendário e cronograma.
///
/// Exibe:
/// - Um calendário mensal ([table_calendar]) com marcadores nos dias
///   que têm tarefas.
/// - Abaixo, a lista de tarefas do dia selecionado (agenda/cronograma).
///
/// Ao tocar numa tarefa, abre o [TaskForm] em modo edição (Módulo 1)
/// permitindo alterar data/horário, o que re-agenda a notificação
/// via [TaskController.updateTask].
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController(
      taskRepo: context.read<TaskController>().taskRepo,
    );
    _calendarController.init();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _calendarController,
      child: Column(
        children: [
          // ─── Calendário ─────────────────────────────────
          Consumer<CalendarController>(
            builder: (context, controller, _) {
              return TableCalendar<TaskItem>(
                locale: 'pt_BR',
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                focusedDay: controller.focusedMonth,
                selectedDayPredicate: (day) =>
                    DateHelpers.normalizeToDay(day) ==
                    DateHelpers.normalizeToDay(controller.selectedDay),
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.all,
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectDay(selectedDay);
                  controller.focusMonth(focusedDay);
                },
                onPageChanged: (focusedDay) {
                  controller.focusMonth(focusedDay);
                },
                // Marcadores nos dias que têm tarefas
                eventLoader: (day) => controller.getTasksForDay(day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    return _buildMarker(context, events.length);
                  },
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // ─── Lista de tarefas do dia selecionado ─────────
          Expanded(
            child: Consumer<CalendarController>(
              builder: (context, controller, _) {
                return ScheduleList(
                  tasks: controller.selectedDayTasks,
                  day: controller.selectedDay,
                  showEmptyHeader: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Marcador pequeno indicando quantas tarefas existem no dia.
  Widget _buildMarker(BuildContext context, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          color: Theme.of(context).colorScheme.onSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

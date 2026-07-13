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
  /// Controller opcional para injetar dependências em testes.
  /// Se não fornecido, cria um novo a partir do [TaskController] via Provider.
  final CalendarController? controller;

  const CalendarScreen({super.key, this.controller});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    // Usa o controller injetado (testes) ou cria um novo (produção)
    if (widget.controller != null) {
      _calendarController = widget.controller!;
    } else {
      _calendarController = CalendarController(
        taskRepo: context.read<TaskController>().taskRepo,
      );
      _calendarController.init();
    }
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
                    return _buildMarker(context, events);
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
                    color: Colors.transparent,
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

  /// Marcador visual: bolinhas coloridas indicando tarefas no dia.
  ///
  /// Regras:
  /// - Se todas as [events] estiverem concluídas → bolinhas verdes.
  /// - Senão → bolinhas na cor de destaque do tema (roxo Catppuccin no
  ///   dark, primary no light).
  /// - Mostra no máximo 3 bolinhas; se houver mais, exibe um "+" ao lado.
  /// - O destaque do "hoje" (círculo ao redor do número) permanece intacto.
  Widget _buildMarker(BuildContext context, List<dynamic> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    final tasks = events.cast<TaskItem>();
    final allCompleted = tasks.every((e) => e.isCompleted);
    final brightness = Theme.of(context).brightness;

    // Cores adaptativas
    final dotColor = allCompleted
        ? (brightness == Brightness.dark
            ? const Color(0xFFA6E3A1) // Catppuccin green
            : const Color(0xFF859900)) // Solarized green
        : (brightness == Brightness.dark
            ? const Color(0xFFCBA6F7) // Catppuccin mauve
            : Theme.of(context).colorScheme.primary); // Primary do tema light

    const dotSize = 5.0;
    const dotSpacing = 2.0;
    final count = tasks.length;
    final dotsToShow = count > 3 ? 3 : count;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < dotsToShow; i++)
          Container(
            width: dotSize,
            height: dotSize,
            margin: const EdgeInsets.symmetric(horizontal: dotSpacing / 2),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        if (count > 3)
          Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 8,
                color: dotColor,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

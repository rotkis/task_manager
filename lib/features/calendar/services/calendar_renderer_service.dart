import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/date_helpers.dart';
import '../../../data/models/task_item.dart';

/// Serviço que renderiza o calendário de um mês como PNG offscreen
/// e salva num arquivo local para ser exibido pelo widget nativo Android.
/// O cabeçalho com o nome do mês e as setas de navegação ficam no
/// layout XML do widget ([calendar_widget_layout.xml]) — o PNG contém
/// apenas os labels dos dias da semana e o grid de dias.
class CalendarRendererService {
  /// Gera a imagem do calendário do mês [year]/[month] com base nas
  /// [tasks] e salva em `calendar_{year}_{month}.png`.
  ///
  /// Se [year] e [month] não forem fornecidos, usa o mês corrente.
  /// Detecta o tema do sistema (dark/light) para as cores.
  static Future<File?> renderAndSave({
    required List<TaskItem> tasks,
    int? year,
    int? month,
  }) async {
    try {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDarkMode = brightness == Brightness.dark;
      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      // Filtra tarefas do mês alvo
      final monthStart =
          DateHelpers.normalizeToDay(DateTime(targetYear, targetMonth, 1));
      final monthEnd =
          DateHelpers.normalizeToDay(DateTime(targetYear, targetMonth + 1, 0));

      final monthTasks = tasks.where((t) {
        if (t.scheduledDate == null) return false;
        final d = DateHelpers.normalizeToDay(t.scheduledDate!);
        return !d.isBefore(monthStart) && !d.isAfter(monthEnd);
      }).toList();

      // Mapa dia -> (count, allDone) para desenhar bolinhas
      // Regra: verde se TODAS concluídas, roxo/destaque se alguma pendente.
      // Máximo 3 bolinhas visíveis + "+N" se mais de 3 tarefas no dia.
      final Map<int, ({int count, bool allDone})> daySummary = {};
      for (final task in monthTasks) {
        if (task.scheduledDate == null) continue;
        final day = task.scheduledDate!.day;
        final current = daySummary[day] ?? (count: 0, allDone: true);
        daySummary[day] = (
          count: current.count + 1,
          allDone: current.allDone && task.isCompleted,
        );
      }

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Tamanho do widget: 250x250 dp (escala 2x = 500x500 px para qualidade)
      const double scale = 2.0;
      const double sizeDp = 250.0;
      const double sizePx = sizeDp * scale;

      // Cores baseadas no tema
      final Color bgColor =
          isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFFFF8E7);
      final Color textColor =
          isDarkMode ? const Color(0xFFCDD6F4) : const Color(0xFF4A3B2A);
      final Color subTextColor =
          isDarkMode ? const Color(0xFF6C6F93) : const Color(0xFF8B7D6B);
      const Color greenDotColor = Color(0xFFA6E3A1); // verde (tudo concluído)
      const Color accentDotColor = Color(0xFFCBA6F7); // roxo (alguma pendente)
      final Color todayRingColor =
          isDarkMode ? const Color(0xFFCBA6F7) : const Color(0xFF8B5A3C);
      final Color weekendColor =
          isDarkMode ? const Color(0xFF45475A) : const Color(0xFFE8D5B7);

      const double cellSize = sizePx / 7.0;
      const double dayLabelHeight = 24.0 * scale;
      // O cabeçalho está no XML layout, não no PNG
      const double totalHeight = sizePx + dayLabelHeight;

      // Fundo
      canvas.drawRect(
        Rect.fromLTWH(0, 0, sizePx, totalHeight),
        Paint()..color = bgColor,
      );

      // --- Labels dos dias da semana ---
      final dayLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final dayLabelPainter = TextPainter(textDirection: TextDirection.ltr);
      for (int i = 0; i < 7; i++) {
        dayLabelPainter.text = TextSpan(
          text: dayLabels[i],
          style: TextStyle(
            color: (i == 0 || i == 6) ? subTextColor : textColor,
            fontSize: 11.0 * scale,
            fontWeight: FontWeight.w500,
          ),
        );
        dayLabelPainter.layout(minWidth: 0, maxWidth: cellSize);
        dayLabelPainter.paint(
          canvas,
          Offset(
            i * cellSize + (cellSize - dayLabelPainter.width) / 2,
            4.0 * scale,
          ),
        );
      }

      // --- Grid dos dias ---
      final firstDayOfMonth = DateTime(targetYear, targetMonth, 1);
      final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Dom, 6=Sáb
      final daysInMonth = DateTime(targetYear, targetMonth + 1, 0).day;

      final today = DateHelpers.today();

      final dayNumberPainter = TextPainter(textDirection: TextDirection.ltr);

      // Só destaca "hoje" se o mês renderizado for o mês corrente
      final bool isCurrentMonth =
          targetYear == today.year && targetMonth == today.month;

      // Constantes das bolinhas (mesma lógica do in-app calendar)
      const int maxDots = 3;
      const double dotRadius = 2.5 * scale; // 5px
      const double dotSpacing = 1.0 * scale; // 2px
      // O número do dia fica no topo da célula
      const double dayNumberFontSize = 14.0 * scale; // 28px
      const double dayNumberY = 6.0 * scale; // 12px do topo
      // Bolinhas aparecem na parte inferior da célula
      const double dotY = cellSize - 6.0 * scale; // 12px do fundo

      int day = 1;
      for (int week = 0; week < 6 && day <= daysInMonth; week++) {
        for (int weekday = 0; weekday < 7 && day <= daysInMonth; weekday++) {
          if (week == 0 && weekday < firstWeekday) continue;

          final x = weekday * cellSize;
          final y = dayLabelHeight + week * cellSize;
          final cellRect = Rect.fromLTWH(x, y, cellSize, cellSize);

          // Fim de semana: fundo sutil
          if (weekday == 0 || weekday == 6) {
            canvas.drawRect(cellRect, Paint()..color = weekendColor);
          }

          // Hoje: anel (só se for o mês corrente)
          if (isCurrentMonth && day == today.day) {
            final ringPaint = Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0 * scale
              ..color = todayRingColor;
            canvas.drawRect(
              cellRect.deflate(4.0 * scale),
              ringPaint,
            );
          }

          // Número do dia
          dayNumberPainter.text = TextSpan(
            text: '$day',
            style: TextStyle(
              color: textColor,
              fontSize: dayNumberFontSize,
              fontWeight: FontWeight.w500,
            ),
          );
          dayNumberPainter.layout(minWidth: 0, maxWidth: cellSize);
          dayNumberPainter.paint(
            canvas,
            Offset(
              x + (cellSize - dayNumberPainter.width) / 2,
              y + dayNumberY,
            ),
          );

          // Bolinhas de status (mesma regra do in-app calendar)
          // - Se TODAS as tarefas do dia estão concluídas → verde
          // - Senão → roxo/destaque
          // - Máximo 3 bolinhas; se mais de 3 tarefas, "+N" excedente
          final summary = daySummary[day];
          if (summary != null && summary.count > 0) {
            final dotPaint = Paint()..style = PaintingStyle.fill;
            dotPaint.color = summary.allDone ? greenDotColor : accentDotColor;

            final dotsToShow =
                summary.count > maxDots ? maxDots : summary.count;
            // Centraliza as bolinhas
            final totalDotsWidth =
                dotsToShow * (dotRadius * 2) + (dotsToShow - 1) * dotSpacing;
            final startX = x + (cellSize - totalDotsWidth) / 2;

            for (int i = 0; i < dotsToShow; i++) {
              final cx = startX + i * (dotRadius * 2 + dotSpacing) + dotRadius;
              canvas.drawCircle(Offset(cx, y + dotY), dotRadius, dotPaint);
            }

            // "+N" se houver overflow
            if (summary.count > maxDots) {
              final overflow = summary.count - maxDots;
              final overflowPainter = TextPainter(
                text: TextSpan(
                  text: '+$overflow',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 7.0 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                textDirection: TextDirection.ltr,
              );
              overflowPainter.layout();
              // Posiciona logo após as bolinhas
              final overflowX =
                  startX + dotsToShow * (dotRadius * 2 + dotSpacing);
              overflowPainter.paint(
                canvas,
                Offset(overflowX,
                    y + dotY - overflowPainter.height / 2 + 1.0 * scale),
              );
            }
          }

          day++;
        }
      }

      // Finaliza e salva
      final picture = recorder.endRecording();
      final img = await picture.toImage(sizePx.toInt(), totalHeight.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/calendar_${targetYear}_$targetMonth.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return file;
    } catch (e) {
      // Falha silenciosa — widget nativo ficará vazio mas não quebra o app
      return null;
    }
  }
}

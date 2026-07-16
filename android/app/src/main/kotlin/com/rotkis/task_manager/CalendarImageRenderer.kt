package com.rotkis.task_manager

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.util.Calendar

/**
 * Renderiza o grid mensal do calendário como PNG usando a Canvas API
 * do Android, sem depender do Flutter.
 *
 * Lê os dados de tarefas de [HomeWidgetPreferences] com a chave
 * `calendar_tasks_data_{year}_{month}` (JSON salvo pelo Flutter) no
 * formato `{"5": {"n": 3, "d": false}, "7": {"n": 1, "d": true}}`:
 * - `n`: total de tarefas no dia
 * - `d`: `true` se TODAS concluídas, `false` se alguma pendente
 *
 * Regra das bolinhas (mesma do in-app [CalendarScreen]):
 * - Se TODAS concluídas → verde (#A6E3A1)
 * - Senão → roxo/destaque (#CBA6F7)
 * - Máximo 3 bolinhas visíveis; "+N" se mais de 3 tarefas no dia
 *
 * O cabeçalho com o nome do mês e as setas de navegação fica no
 * layout XML ([calendar_widget_layout.xml]).
 */
object CalendarImageRenderer {

    private const val PREFS_NAME = "HomeWidgetPreferences"

    /**
     * Gera o PNG do calendário para [year]/[month] e salva em
     * `calendar_{year}_{month}.png` no diretório de arquivos do app.
     */
    fun render(context: Context, year: Int, month: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // ── Dimensões (mesmas do Flutter renderer, scale 2x) ──────
        val scale = 2.0f
        val sizeDp = 250f
        val sizePx = (sizeDp * scale).toInt() // 500px
        val cellSize = sizePx / 7.0f           // ~71.4px
        val dayLabelHeight = (24f * scale).toInt() // 48px
        val totalHeight = sizePx + dayLabelHeight  // 548px

        val bitmap = Bitmap.createBitmap(sizePx, totalHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // ── Cores (tema escuro Catppuccin Mocha) ──────────────────
        val bgColor = 0xFF1E1E2E.toInt()
        val textColor = 0xFFCDD6F4.toInt()
        val subTextColor = 0xFF6C6F93.toInt()
        val greenDotColor = 0xFFA6E3A1.toInt()
        val accentDotColor = 0xFFCBA6F7.toInt()
        val todayRingColor = 0xFFCBA6F7.toInt()
        val weekendColor = 0xFF45475A.toInt()

        // ── Paints ──────────────────────────────────────────────
        val bgPaint = Paint().apply { color = bgColor }

        val textPaint = Paint().apply {
            color = textColor
            isAntiAlias = true
            typeface = Typeface.DEFAULT
        }

        val subTextPaint = Paint().apply {
            color = subTextColor
            isAntiAlias = true
            typeface = Typeface.DEFAULT
        }

        val weekendPaint = Paint().apply { color = weekendColor }

        val todayRingPaint = Paint().apply {
            style = Paint.Style.STROKE
            strokeWidth = 4f
            color = todayRingColor
            isAntiAlias = true
        }

        // ── Fundo ────────────────────────────────────────────────
        canvas.drawRect(0f, 0f, sizePx.toFloat(), totalHeight.toFloat(), bgPaint)

        // ── Labels dos dias da semana ────────────────────────────
        val dayLabels = arrayOf("Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb")
        val dayLabelFontSize = 22f // 11sp * 2
        for (i in 0 until 7) {
            val paint = if (i == 0 || i == 6) subTextPaint else textPaint
            paint.textSize = dayLabelFontSize
            val textWidth = paint.measureText(dayLabels[i])
            val xLabel = i * cellSize + (cellSize - textWidth) / 2f
            canvas.drawText(dayLabels[i], xLabel, 8f + dayLabelFontSize, paint)
        }

        // ── Datas do calendário ──────────────────────────────────
        val calendar = Calendar.getInstance()
        calendar.set(year, month - 1, 1)

        @Suppress("DEPRECATION")
        val firstDayWeek = calendar.get(Calendar.DAY_OF_WEEK)
        val firstWeekday = (firstDayWeek + 6) % 7
        val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)

        val today = Calendar.getInstance()
        val todayYear = today.get(Calendar.YEAR)
        val todayMonth = today.get(Calendar.MONTH) + 1
        val todayDay = today.get(Calendar.DAY_OF_MONTH)

        // ── Dados de tarefas (formato: dia → {n, d}) ────────────
        val tasksJsonStr = prefs.getString("calendar_tasks_data_${year}_$month", "{}") ?: "{}"
        val tasksJson: JSONObject = try {
            JSONObject(tasksJsonStr)
        } catch (_: Exception) {
            JSONObject()
        }

        // Constantes das bolinhas (mesma lógica do in-app calendar)
        val maxDots = 3
        val dotRadius = 5f    // 2.5sp * 2
        val dotSpacing = 2f   // 1sp * 2
        val dayNumberFontSize = 28f // 14sp * 2
        val dayNumberY = 12f       // 6sp * 2
        val dotY = cellSize - 12f  // 6sp * 2 do fundo

        var day = 1
        weekLoop@ for (week in 0 until 6) {
            if (day > daysInMonth) break
            for (weekday in 0 until 7) {
                if (day > daysInMonth) break@weekLoop
                if (week == 0 && weekday < firstWeekday) continue

                val x = weekday * cellSize
                val y = dayLabelHeight + week * cellSize

                // Fundo de fim de semana
                if (weekday == 0 || weekday == 6) {
                    canvas.drawRect(x, y, x + cellSize, y + cellSize, weekendPaint)
                }

                // Anel do dia atual
                if (year == todayYear && month == todayMonth && day == todayDay) {
                    canvas.drawRect(
                        x + 8f, y + 8f, x + cellSize - 8f, y + cellSize - 8f,
                        todayRingPaint
                    )
                }

                // Número do dia
                textPaint.textSize = dayNumberFontSize
                val dayStr = day.toString()
                val dayWidth = textPaint.measureText(dayStr)
                val textX = x + (cellSize - dayWidth) / 2f
                val textY = y + dayNumberY + dayNumberFontSize
                canvas.drawText(dayStr, textX, textY, textPaint)

                // ── Bolinhas de status ──────────────────────────
                val dayKey = day.toString()
                if (tasksJson.has(dayKey)) {
                    val dayObj = tasksJson.optJSONObject(dayKey)
                    if (dayObj != null) {
                        val totalTasks = dayObj.optInt("n", 0)
                        val allDone = dayObj.optBoolean("d", true)

                        if (totalTasks > 0) {
                            val dotPaint = Paint().apply {
                                color = if (allDone) greenDotColor else accentDotColor
                                style = Paint.Style.FILL
                                isAntiAlias = true
                            }

                            val dotsToShow = if (totalTasks > maxDots) maxDots else totalTasks
                            val totalDotsWidth =
                                dotsToShow * (dotRadius * 2) + (dotsToShow - 1) * dotSpacing
                            val startX = x + (cellSize - totalDotsWidth) / 2f

                            for (i in 0 until dotsToShow) {
                                val cx = startX + i * (dotRadius * 2 + dotSpacing) + dotRadius
                                canvas.drawCircle(cx, y + dotY, dotRadius, dotPaint)
                            }

                            // "+N" se overflow
                            if (totalTasks > maxDots) {
                                val overflow = totalTasks - maxDots
                                subTextPaint.textSize = 14f // 7sp * 2
                                val overflowText = "+$overflow"
                                val overflowX =
                                    startX + dotsToShow * (dotRadius * 2 + dotSpacing)
                                canvas.drawText(
                                    overflowText,
                                    overflowX,
                                    y + dotY + 5f,
                                    subTextPaint
                                )
                            }
                        }
                    }
                }

                day++
            }
        }

        // ── Salva PNG ────────────────────────────────────────────
        val dir = context.filesDir
        val file = File(dir, "calendar_${year}_$month.png")
        file.parentFile?.mkdirs()
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
    }
}

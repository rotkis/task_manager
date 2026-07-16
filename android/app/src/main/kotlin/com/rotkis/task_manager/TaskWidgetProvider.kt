package com.rotkis.task_manager

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.View
import android.widget.RemoteViews

/**
 * Widget 2 — Tarefas de hoje + streak.
 *
 * Estende [AppWidgetProvider] diretamente (NÃO [HomeWidgetProvider]).
 * Lê dados do SharedPreferences "HomeWidgetPreferences":
 * - pending_count, streak: contadores
 * - schedule_1..schedule_5: "HH:mm|Título" das tarefas pendentes de hoje
 * - schedule_count: total de tarefas pendentes
 */
class TaskWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val TAG = "TaskWidget"
        private const val PREFS_NAME = "HomeWidgetPreferences"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            val pkg = context.packageName
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val res = context.resources

            Log.d(TAG, "onUpdate chamado para ${appWidgetIds.size} widget(s)")

            val openIntent = Intent().apply {
                setClassName(pkg, "$pkg.MainActivity")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Resolve IDs das views uma vez (fora do apply)
            val rowIds = IntArray(5) { i ->
                val id = res.getIdentifier("task_row_${i + 1}", "id", pkg)
                if (id == 0) Log.w(TAG, "task_row_${i + 1} not found!")
                id
            }
            val timeIds = IntArray(5) { i ->
                val id = res.getIdentifier("task_time_${i + 1}", "id", pkg)
                if (id == 0) Log.w(TAG, "task_time_${i + 1} not found!")
                id
            }
            val titleIds = IntArray(5) { i ->
                val id = res.getIdentifier("task_title_${i + 1}", "id", pkg)
                if (id == 0) Log.w(TAG, "task_title_${i + 1} not found!")
                id
            }

            appWidgetIds.forEach { appWidgetId ->
                val pendingCount = prefs.getString("pending_count", "0") ?: "0"
                val streak = prefs.getString("streak", "0") ?: "0"

                Log.d(TAG, "Widget $appWidgetId: pending_count=$pendingCount, streak=$streak")

                val taskCount = prefs.getString("schedule_count", "0")?.toIntOrNull() ?: 0
                Log.d(TAG, "Widget $appWidgetId: schedule_count=$taskCount")

                // Lê até 5 tarefas e LOG cada uma
                val tasks = mutableListOf<String>()
                for (i in 1..5) {
                    val line = prefs.getString("schedule_$i", "") ?: ""
                    Log.d(TAG, "Widget $appWidgetId: schedule_$i='$line'")
                    if (line.isNotEmpty()) tasks.add(line)
                }

                Log.d(TAG, "Widget $appWidgetId: ${tasks.size} tarefas lidas do prefs")

                val views = RemoteViews(pkg, R.layout.task_widget_layout).apply {
                    // Topo: contadores com rótulos
                    setTextViewText(R.id.tv_pending_count, "$pendingCount pendentes")
                    setTextViewText(R.id.tv_streak, "${streak}d streak")

                    // Preenche até 5 linhas de tarefa
                    for (i in 0 until 5) {
                        if (i < tasks.size) {
                            val parts = tasks[i].split("|", limit = 2)
                            val time = if (parts.size == 2) parts[0] else ""
                            val title = if (parts.size == 2) parts[1] else tasks[i]

                            Log.d(TAG, "Widget $appWidgetId: linha ${i+1}: time='$time' title='$title'")

                            setTextViewText(timeIds[i], time)
                            setTextViewText(titleIds[i], title)
                            setViewVisibility(rowIds[i], View.VISIBLE)
                        } else {
                            setViewVisibility(rowIds[i], View.GONE)
                        }
                    }

                    // Overflow
                    val overflow = taskCount - 5
                    if (overflow > 0) {
                        setTextViewText(R.id.tv_more, "+$overflow mais")
                        setViewVisibility(R.id.tv_more, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.tv_more, View.GONE)
                    }

                    // Empty state
                    if (taskCount == 0) {
                        setViewVisibility(R.id.tv_empty, View.VISIBLE)
                    } else {
                        setViewVisibility(R.id.tv_empty, View.GONE)
                    }

                    setOnClickPendingIntent(R.id.root_layout, pendingIntent)
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Widget $appWidgetId atualizado")
            }
        } catch (e: Exception) {
            Log.e(TAG, "onUpdate failed", e)
        }
    }
}
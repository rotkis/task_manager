package com.rotkis.task_manager

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.RemoteViews
import java.io.File
import java.util.Calendar

/**
 * Widget que exibe o calendário de um mês como imagem PNG gerada pelo
 * Flutter ([CalendarRendererService]) ou pelo Kotlin ([CalendarImageRenderer]).
 *
 * Cada instância do widget (appWidgetId) pode estar exibindo um mês
 * diferente, controlado pelo offset salvo em SharedPreferences com a
 * chave `calendar_month_offset_{appWidgetId}`.
 *
 * Os botões ◀ e ▶ no cabeçalho disparam [CalendarWidgetNavReceiver]
 * para navegar entre meses sem precisar abrir o app.
 */
class CalendarWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "CalendarWidget"
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
            val navHelper = CalendarWidgetNavReceiver()

            // Intent para abrir o app ao clicar no fundo
            val openIntent = Intent().apply {
                setClassName(pkg, "$pkg.MainActivity")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPending = android.app.PendingIntent.getActivity(
                context, 0, openIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )

            val monthNames = arrayOf(
                "Janeiro", "Fevereiro", "Março", "Abril",
                "Maio", "Junho", "Julho", "Agosto",
                "Setembro", "Outubro", "Novembro", "Dezembro"
            )

            appWidgetIds.forEach { appWidgetId ->
                // Lê o offset deste widget específico
                val offsetStr =
                    prefs.getString("calendar_month_offset_$appWidgetId", "0") ?: "0"
                val offset = offsetStr.toIntOrNull() ?: 0

                // Calcula ano/mês alvo
                val now = Calendar.getInstance()
                val target = Calendar.getInstance().apply {
                    set(Calendar.YEAR, now.get(Calendar.YEAR))
                    set(Calendar.MONTH, now.get(Calendar.MONTH) + offset)
                }
                val year = target.get(Calendar.YEAR)
                val month = target.get(Calendar.MONTH) + 1 // 1-indexed

                Log.d(TAG, "Widget $appWidgetId: offset=$offset → ${year}_$month")

                // Garante que o PNG existe
                val file = File(context.filesDir, "calendar_${year}_$month.png")
                if (!file.exists()) {
                    Log.d(TAG, "PNG não existe, renderizando via CalendarImageRenderer")
                    CalendarImageRenderer.render(context, year, month)
                }

                val views = RemoteViews(pkg, R.layout.calendar_widget_layout).apply {
                    // Título do mês
                    setTextViewText(R.id.tv_calendar_title, "${monthNames[month - 1]} $year")

                    // Botões de navegação
                    navHelper.setNavPendingIntents(context, this, appWidgetId)

                    // Abrir app ao tocar no título
                    setOnClickPendingIntent(R.id.tv_calendar_title, openPending)

                    // Tocar no fundo também abre o app (para quem clicar fora dos botões)
                    setOnClickPendingIntent(R.id.root_layout, openPending)

                    // Carrega o PNG do calendário
                    if (file.exists()) {
                        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                        if (bitmap != null) {
                            setImageViewBitmap(R.id.iv_calendar, bitmap)
                        } else {
                            Log.w(TAG, "Bitmap nulo para ${file.absolutePath}")
                        }
                    } else {
                        Log.w(TAG, "PNG não encontrado após render: ${file.absolutePath}")
                    }
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        } catch (e: Exception) {
            Log.e(TAG, "onUpdate failed", e)
        }
    }
}

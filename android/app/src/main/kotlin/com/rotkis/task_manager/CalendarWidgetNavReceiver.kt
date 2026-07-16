package com.rotkis.task_manager

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.util.Log
import android.widget.RemoteViews
import java.io.File
import java.util.Calendar

/**
 * Recebe os broadcasts dos botões de navegação ◀ (anterior) e ▶
 * (próximo) do widget de calendário.
 *
 * Para cada widget (identificado por [AppWidgetManager.EXTRA_APPWIDGET_ID]):
 * 1. Lê o offset de mês atual de [HomeWidgetPreferences]
 * 2. Incrementa/decrementa o offset
 * 3. Persiste o novo offset
 * 4. Gera o PNG do calendário para o novo mês via [CalendarImageRenderer]
 * 5. Atualiza APENAS aquele widget específico via [AppWidgetManager.updateAppWidget]
 */
class CalendarWidgetNavReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "CalendarNav"
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val ACTION_PREV = "ACTION_NAV_PREV"
        private const val ACTION_NEXT = "ACTION_NAV_NEXT"

        // Constantes para request codes dos PendingIntents
        const val REQUEST_CODE_PREV_BASE = 1000
        const val REQUEST_CODE_NEXT_BASE = 2000
    }

    override fun onReceive(context: Context, intent: Intent) {
        try {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
                Log.w(TAG, "onReceive sem appWidgetId")
                return
            }

            val action = intent.action ?: return
            val delta = when (action) {
                ACTION_PREV -> -1
                ACTION_NEXT -> +1
                else -> return
            }

            Log.d(TAG, "Widget $appWidgetId: $action (delta=$delta)")

            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val currentOffset =
                prefs.getString("calendar_month_offset_$appWidgetId", "0")?.toIntOrNull() ?: 0
            val newOffset = currentOffset + delta

            // Persiste o novo offset
            prefs.edit().putString("calendar_month_offset_$appWidgetId", newOffset.toString()).apply()

            // Calcula ano/mês alvo
            val now = Calendar.getInstance()
            val target = Calendar.getInstance().apply {
                set(Calendar.YEAR, now.get(Calendar.YEAR))
                set(Calendar.MONTH, now.get(Calendar.MONTH) + newOffset)
            }
            val year = target.get(Calendar.YEAR)
            val month = target.get(Calendar.MONTH) + 1 // 1-indexed

            Log.d(TAG, "Renderizando calendário para ${year}_$month (offset=$newOffset)")

            // Gera o PNG (se o Flutter já salvou dados de tarefa, as
            // bolinhas de status aparecerão; senão, só o grid básico)
            CalendarImageRenderer.render(context, year, month)

            // Atualiza o widget específico
            val pkg = context.packageName
            val views = RemoteViews(pkg, R.layout.calendar_widget_layout)

            // Título do mês
            val monthNames = arrayOf(
                "Janeiro", "Fevereiro", "Março", "Abril",
                "Maio", "Junho", "Julho", "Agosto",
                "Setembro", "Outubro", "Novembro", "Dezembro"
            )
            views.setTextViewText(R.id.tv_calendar_title, "${monthNames[month - 1]} $year")

            // Botões de navegação
            setNavPendingIntents(context, views, appWidgetId)

            // Abrir app ao tocar no título
            val openIntent = Intent().apply {
                setClassName(pkg, "$pkg.MainActivity")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPending = PendingIntent.getActivity(
                context, appWidgetId, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.tv_calendar_title, openPending)

            // Imagem do calendário
            val file = File(context.filesDir, "calendar_${year}_$month.png")
            if (file.exists()) {
                val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.iv_calendar, bitmap)
                } else {
                    Log.w(TAG, "Bitmap nulo para ${file.absolutePath}")
                }
            } else {
                Log.w(TAG, "PNG não encontrado: ${file.absolutePath}")
            }

            val appWidgetManager = AppWidgetManager.getInstance(context)
            appWidgetManager.updateAppWidget(appWidgetId, views)

            Log.d(TAG, "Widget $appWidgetId atualizado para ${monthNames[month - 1]} $year")
        } catch (e: Exception) {
            Log.e(TAG, "onReceive failed", e)
        }
    }

    /**
     * Configura os PendingIntents de navegação nos botões ◀ e ▶.
     * Chamado tanto pelo [CalendarWidgetNavReceiver] quanto pelo
     * [CalendarWidgetProvider].
     */
    fun setNavPendingIntents(
        context: Context,
        views: RemoteViews,
        appWidgetId: Int
    ) {
        val pkg = context.packageName

        // Botão ◀ (mês anterior)
        val prevIntent = Intent(context, CalendarWidgetNavReceiver::class.java).apply {
            action = ACTION_PREV
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val prevPending = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_PREV_BASE + appWidgetId,
            prevIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_prev_month, prevPending)

        // Botão ▶ (próximo mês)
        val nextIntent = Intent(context, CalendarWidgetNavReceiver::class.java).apply {
            action = ACTION_NEXT
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        val nextPending = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_NEXT_BASE + appWidgetId,
            nextIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_next_month, nextPending)
    }
}

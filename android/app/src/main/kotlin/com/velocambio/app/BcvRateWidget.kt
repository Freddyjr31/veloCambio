package com.velocambio.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class BcvRateWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val rate = widgetData.getString(KEY_RATE, null)
        val date = widgetData.getString(KEY_DATE, null)
        val views = buildViews(context, rate, date)
        appWidgetIds.forEach { id -> appWidgetManager.updateAppWidget(id, views) }
    }

    companion object {
        const val KEY_RATE = "bcv_rate"
        const val KEY_DATE = "bcv_date"

        fun buildViews(context: Context, rate: String?, date: String?): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.bcv_rate_widget)
            views.setTextViewText(R.id.tv_rate, rate ?: "--")
            views.setTextViewText(R.id.tv_date, date ?: "Actualizado: --")

            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            return views
        }
    }
}

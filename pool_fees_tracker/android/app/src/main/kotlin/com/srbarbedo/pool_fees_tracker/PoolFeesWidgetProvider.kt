package com.srbarbedo.pool_fees_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget de ecrã inicial com o total de fees em destaque. Os dados são
 * escritos pelo lado Dart (lib/data/services/home_widget_service.dart),
 * tanto em primeiro plano como na verificação periódica em background de
 * alertas — por isso o widget também atualiza com a app fechada, ainda
 * que só a cada ~15 min nesse caso.
 */
class PoolFeesWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.pool_fees_widget).apply {
            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            setTextViewText(
                R.id.widget_title,
                widgetData.getString("widget_title", null) ?: "TOTAL DE TAXAS GERADAS",
            )
            setTextViewText(
                R.id.widget_total_fees,
                widgetData.getString("value_formatted", null) ?: "—",
            )
            setTextViewText(
                R.id.widget_updated_at,
                widgetData.getString("updated_at_label", null) ?: "Abre a app para atualizar",
            )
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

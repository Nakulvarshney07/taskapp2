package com.example.outtaskapp

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin



/**
 * Implementation of App Widget functionality.
 */
class MotivationWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            // Get reference to SharedPreferences
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.motivation_widget).apply {

                    setImageViewBitmap(R.id.imageView , R.drawable.img)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}


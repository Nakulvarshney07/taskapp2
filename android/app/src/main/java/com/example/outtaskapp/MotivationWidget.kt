package com.example.outtaskapp
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File



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

                val imageName = widgetData.getString("filename", null)
                val imageFile = File(imageName)
                val imageExists = imageFile.exists()
                if (imageExists) {
                    val myBitmap: Bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
                    setImageViewBitmap(R.id.imageView, myBitmap)
                } else {
                    println("image not found!, looked @: ${imageName}")
                }
                    
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}


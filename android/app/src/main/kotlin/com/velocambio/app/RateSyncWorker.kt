package com.velocambio.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class RateSyncWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val prefs = applicationContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val baseUrl = prefs.getString(KEY_BASE_URL, null) ?: DEFAULT_BASE_URL

        val body = withContext(Dispatchers.IO) { fetchRate(baseUrl) }
            ?: return Result.retry()

        return try {
            val json = JSONObject(body)
            val price = json.optDouble("price", Double.NaN)
            if (!price.isNaN() && price > 0) {
                val rate = String.format(Locale.US, "%.3f", price)
                val dateText = formatDate(json.optString("fetched_at", ""))
                prefs.edit()
                    .putString(KEY_RATE, rate)
                    .putString(KEY_DATE, dateText)
                    .putString(KEY_BASE_URL, baseUrl)
                    .apply()
                updateWidget(rate, dateText)
                Result.success()
            } else {
                Result.retry()
            }
        } catch (e: Exception) {
            Result.retry()
        }
    }

    private fun fetchRate(baseUrl: String): String? {
        return try {
            val endpoint = if (baseUrl.endsWith("/")) {
                "${baseUrl}rates/usd_oficial"
            } else {
                "$baseUrl/rates/usd_oficial"
            }
            val conn = URL(endpoint).openConnection() as HttpURLConnection
            conn.connectTimeout = 10_000
            conn.readTimeout = 10_000
            conn.requestMethod = "GET"
            conn.setRequestProperty("Accept", "application/json")
            if (conn.responseCode == 200) {
                BufferedReader(InputStreamReader(conn.inputStream)).use { it.readText() }
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun formatDate(iso: String): String {
        return try {
            if (iso.isEmpty()) return "Actualizado: --"
            val input = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
            val date: Date = input.parse(iso) ?: return "Actualizado: --"
            val output = SimpleDateFormat("dd/MM HH:mm", Locale.getDefault())
            "Actualizado: ${output.format(date)}"
        } catch (e: Exception) {
            "Actualizado: --"
        }
    }

    private fun updateWidget(rate: String, date: String) {
        val context = applicationContext
        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, BcvRateWidget::class.java)
        val ids = manager.getAppWidgetIds(component)
        if (ids.isEmpty()) return
        val views = BcvRateWidget.buildViews(context, rate, date)
        manager.updateAppWidget(ids, views)
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val KEY_RATE = "bcv_rate"
        private const val KEY_DATE = "bcv_date"
        private const val KEY_BASE_URL = "bcv_base_url"
        const val DEFAULT_BASE_URL = "http://10.0.2.2:9000/"
    }
}

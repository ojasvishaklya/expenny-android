package com.ojasvishaklya.expenny

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import androidx.core.content.ContextCompat
import java.text.NumberFormat
import java.util.Calendar
import java.util.Locale

class SpendWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "SpendWidget"
        private const val MONTHLY_BUDGET = 40000.0
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.spend_widget)

                // Get current month info
                val calendar = Calendar.getInstance()
                val year = calendar.get(Calendar.YEAR)
                val month = calendar.get(Calendar.MONTH) + 1
                val monthName = calendar.getDisplayName(
                    Calendar.MONTH, Calendar.LONG, Locale.ENGLISH
                )?.uppercase() ?: "UNKNOWN"

                // Query SQLite for current month expenses
                val totalSpend = queryMonthlySpend(context, year, month)
                val budgetLeft = MONTHLY_BUDGET - totalSpend
                val percentage = ((totalSpend / MONTHLY_BUDGET) * 100).coerceIn(0.0, 100.0).toInt()

                Log.d(TAG, "Month: $monthName, Spend: $totalSpend, Left: $budgetLeft, %: $percentage")

                // Format amounts
                val spentFormatted = formatCurrency(totalSpend)
                val budgetTotalFormatted = "/ " + formatCurrency(MONTHLY_BUDGET)
                val remainingFormatted = formatCurrency(Math.abs(budgetLeft))

                // Set header (e.g., "JUNE BUDGET")
                views.setTextViewText(R.id.widget_month, "$monthName BUDGET")

                // Set main spent amount
                views.setTextViewText(R.id.widget_spent_amount, spentFormatted)
                views.setTextViewText(R.id.widget_budget_total, budgetTotalFormatted)

                // Set progress bar
                views.setProgressBar(R.id.widget_progress, 100, percentage, false)

                // Set remaining text
                val remainingText = if (budgetLeft >= 0) {
                    "$remainingFormatted remaining"
                } else {
                    "$remainingFormatted over budget"
                }
                views.setTextViewText(R.id.widget_remaining, remainingText)

                // Color the remaining text
                val remainingColorRes = if (budgetLeft >= 0) {
                    R.color.widget_budget_positive
                } else {
                    R.color.widget_budget_negative
                }
                views.setTextColor(R.id.widget_remaining, ContextCompat.getColor(context, remainingColorRes))

                // Set percentage
                views.setTextViewText(R.id.widget_percentage, "$percentage%")

                // Color percentage based on thresholds
                val percentColorRes = when {
                    percentage >= 100 -> R.color.widget_progress_danger
                    percentage >= 80 -> R.color.widget_progress_warning
                    else -> R.color.widget_text_secondary
                }
                views.setTextColor(R.id.widget_percentage, ContextCompat.getColor(context, percentColorRes))

                // Tap to open
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Widget $appWidgetId updated successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update widget $appWidgetId", e)
                try {
                    val fallback = RemoteViews(context.packageName, R.layout.spend_widget)
                    fallback.setTextViewText(R.id.widget_month, "BUDGET")
                    fallback.setTextViewText(R.id.widget_spent_amount, "\u20B90")
                    fallback.setTextViewText(R.id.widget_budget_total, "/ \u20B940,000")
                    fallback.setTextViewText(R.id.widget_remaining, "\u20B940,000 remaining")
                    fallback.setTextViewText(R.id.widget_percentage, "0%")
                    fallback.setProgressBar(R.id.widget_progress, 100, 0, false)
                    appWidgetManager.updateAppWidget(appWidgetId, fallback)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Even fallback failed", fallbackError)
                }
            }
        }
    }

    private fun queryMonthlySpend(context: Context, year: Int, month: Int): Double {
        var totalSpend = 0.0
        try {
            val dbPath = context.getDatabasePath("transactions.db").absolutePath
            Log.d(TAG, "DB path: $dbPath")

            val dbFile = java.io.File(dbPath)
            if (!dbFile.exists()) {
                Log.d(TAG, "DB file does not exist yet")
                return 0.0
            }

            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)
            val startDate = String.format("%04d-%02d-01T00:00:00.000", year, month)

            Log.d(TAG, "Querying expenses since: $startDate")
            val cursor = db.rawQuery(
                "SELECT SUM(amount) FROM transactions WHERE isExpense = 1 AND date >= ?",
                arrayOf(startDate)
            )

            if (cursor.moveToFirst() && !cursor.isNull(0)) {
                totalSpend = Math.abs(cursor.getDouble(0))
            }
            cursor.close()
            db.close()
            Log.d(TAG, "Total spend: $totalSpend")
        } catch (e: Exception) {
            Log.e(TAG, "DB query failed", e)
            totalSpend = 0.0
        }
        return totalSpend
    }

    private fun formatCurrency(amount: Double): String {
        return "\u20B9" + NumberFormat.getNumberInstance(Locale("en", "IN")).apply {
            maximumFractionDigits = 0
        }.format(amount)
    }
}

package com.ojasvishaklya.expenny

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import java.text.NumberFormat
import java.util.Calendar
import java.util.Locale

class SpendWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val MONTHLY_BUDGET = 40000.0
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.spend_widget)

            // Get current month info
            val calendar = Calendar.getInstance()
            val year = calendar.get(Calendar.YEAR)
            val month = calendar.get(Calendar.MONTH) + 1 // 1-indexed
            val monthName = calendar.getDisplayName(
                Calendar.MONTH, Calendar.LONG, Locale.getDefault()
            ) ?: "Unknown"

            // Query SQLite for current month expenses
            val totalSpend = queryMonthlySpend(context, year, month)
            val budgetLeft = MONTHLY_BUDGET - totalSpend

            // Format amounts with Indian locale (₹ with commas)
            val spentFormatted = formatIndianCurrency(totalSpend)
            val budgetFormatted = formatIndianCurrency(Math.abs(budgetLeft))

            // Set month name
            views.setTextViewText(R.id.widget_month, monthName)

            // Set spent amount
            views.setTextViewText(R.id.widget_spent_amount, spentFormatted)

            // Set budget left amount and color
            val budgetText = if (budgetLeft >= 0) budgetFormatted else "-$budgetFormatted"
            views.setTextViewText(R.id.widget_budget_amount, budgetText)

            // Color: green if positive, red if overspent
            val budgetColor = if (budgetLeft >= 0) 0xFF388E3C.toInt() else 0xFFD32F2F.toInt()
            views.setTextColor(R.id.widget_budget_amount, budgetColor)

            // Tap to open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun queryMonthlySpend(context: Context, year: Int, month: Int): Double {
        var totalSpend = 0.0
        try {
            val dbPath = context.getDatabasePath("transactions.db").absolutePath
            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)

            val startDate = String.format("%04d-%02d-01T00:00:00.000", year, month)
            val cursor = db.rawQuery(
                "SELECT SUM(amount) FROM transactions WHERE isExpense = 1 AND date >= ?",
                arrayOf(startDate)
            )

            if (cursor.moveToFirst() && !cursor.isNull(0)) {
                totalSpend = Math.abs(cursor.getDouble(0))
            }
            cursor.close()
            db.close()
        } catch (e: Exception) {
            // DB may not exist yet (fresh install) — return 0
            totalSpend = 0.0
        }
        return totalSpend
    }

    private fun formatIndianCurrency(amount: Double): String {
        val formatter = NumberFormat.getCurrencyInstance(Locale("en", "IN"))
        formatter.maximumFractionDigits = 0
        return formatter.format(amount)
    }
}

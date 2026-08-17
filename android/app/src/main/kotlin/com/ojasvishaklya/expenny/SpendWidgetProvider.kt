package com.ojasvishaklya.expenny

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.util.Log
import androidx.core.content.ContextCompat
import java.text.NumberFormat
import java.util.Locale

class SpendWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "SpendWidget"

        // SharedPreferences file used by the home_widget Flutter plugin.
        private const val PREFS_NAME = "HomeWidgetPreferences"

        // Keys pushed from Dart (see WidgetService.dart). Numbers are stored as
        // strings for robust cross-version parsing.
        private const val KEY_MONTH = "widget_month"
        private const val KEY_SPENT = "widget_spent"
        private const val KEY_BUDGET = "widget_budget"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.spend_widget)

                // Read the values Flutter pushed into the home_widget prefs.
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val monthHeader = prefs.getString(KEY_MONTH, "BUDGET") ?: "BUDGET"
                val totalSpend = prefs.getString(KEY_SPENT, "0")?.toDoubleOrNull() ?: 0.0
                val budget = prefs.getString(KEY_BUDGET, "-1")?.toDoubleOrNull() ?: -1.0

                val budgetSet = budget > 0

                Log.d(TAG, "Month: $monthHeader, Spend: $totalSpend, Budget: $budget, set: $budgetSet")

                // Header (e.g., "JUNE BUDGET"), pushed pre-formatted from Dart.
                views.setTextViewText(R.id.widget_month, monthHeader)

                // Main spent amount is always shown.
                views.setTextViewText(R.id.widget_spent_amount, formatCurrency(totalSpend))

                if (budgetSet) {
                    val budgetLeft = budget - totalSpend
                    val percentage =
                        ((totalSpend / budget) * 100).coerceIn(0.0, 100.0).toInt()

                    views.setTextViewText(
                        R.id.widget_budget_total, "/ " + formatCurrency(budget)
                    )

                    // Progress bar.
                    views.setProgressBar(R.id.widget_progress, 100, percentage, false)

                    // Remaining / over-budget text.
                    val remainingFormatted = formatCurrency(Math.abs(budgetLeft))
                    val remainingText = if (budgetLeft >= 0) {
                        "$remainingFormatted remaining"
                    } else {
                        "$remainingFormatted over budget"
                    }
                    views.setTextViewText(R.id.widget_remaining, remainingText)

                    val remainingColorRes = if (budgetLeft >= 0) {
                        R.color.widget_budget_positive
                    } else {
                        R.color.widget_budget_negative
                    }
                    views.setTextColor(
                        R.id.widget_remaining,
                        ContextCompat.getColor(context, remainingColorRes)
                    )

                    // Percentage text + threshold colouring.
                    views.setTextViewText(R.id.widget_percentage, "$percentage%")
                    val percentColorRes = when {
                        percentage >= 100 -> R.color.widget_progress_danger
                        percentage >= 80 -> R.color.widget_progress_warning
                        else -> R.color.widget_text_secondary
                    }
                    views.setTextColor(
                        R.id.widget_percentage,
                        ContextCompat.getColor(context, percentColorRes)
                    )
                } else {
                    // No budget configured — render spend gracefully, prompt to set one.
                    views.setTextViewText(R.id.widget_budget_total, "/ \u2014") // "/ —"
                    views.setProgressBar(R.id.widget_progress, 100, 0, false)
                    views.setTextViewText(R.id.widget_remaining, "Set a budget")
                    views.setTextColor(
                        R.id.widget_remaining,
                        ContextCompat.getColor(context, R.color.widget_text_secondary)
                    )
                    views.setTextViewText(R.id.widget_percentage, "")
                }

                // Tap to open.
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
                    fallback.setTextViewText(R.id.widget_budget_total, "/ \u2014")
                    fallback.setTextViewText(R.id.widget_remaining, "Set a budget")
                    fallback.setTextViewText(R.id.widget_percentage, "")
                    fallback.setProgressBar(R.id.widget_progress, 100, 0, false)
                    appWidgetManager.updateAppWidget(appWidgetId, fallback)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Even fallback failed", fallbackError)
                }
            }
        }
    }

    private fun formatCurrency(amount: Double): String {
        return "\u20B9" + NumberFormat.getNumberInstance(Locale("en", "IN")).apply {
            maximumFractionDigits = 0
        }.format(amount)
    }
}

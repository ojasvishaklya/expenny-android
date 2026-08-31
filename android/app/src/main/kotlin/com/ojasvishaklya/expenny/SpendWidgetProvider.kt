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
import kotlin.math.roundToInt

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

        // Number of segments in the progress track.
        private const val SEGMENTS = 10

        // Threshold bands, in percent of budget.
        private const val WARN_AT = 80.0
        private const val DANGER_AT = 100.0
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val segmentIds = resolveSegmentIds(context)

        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.spend_widget)

                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val totalSpend = prefs.getString(KEY_SPENT, "0")?.toDoubleOrNull() ?: 0.0
                val budget = prefs.getString(KEY_BUDGET, "-1")?.toDoubleOrNull() ?: -1.0
                val budgetSet = budget > 0

                val month = prefs.getString(KEY_MONTH, null)?.takeIf { it.isNotBlank() }
                    ?: currentMonthName()

                Log.d(TAG, "Month: $month, Spend: $totalSpend, Budget: $budget, set: $budgetSet")

                views.setTextViewText(R.id.widget_month, month)
                views.setTextViewText(R.id.widget_spent_amount, formatCurrency(totalSpend))

                if (budgetSet) {
                    renderBudget(context, views, segmentIds, totalSpend, budget)
                } else {
                    renderNoBudget(context, views, segmentIds)
                }

                // Tap to open the app.
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
                renderFallback(context, appWidgetManager, appWidgetId, segmentIds)
            }
        }
    }

    /** Renders the populated budget state: amount, of-budget, segments, pill. */
    private fun renderBudget(
        context: Context,
        views: RemoteViews,
        segmentIds: IntArray,
        totalSpend: Double,
        budget: Double
    ) {
        val rawPercent = (totalSpend / budget) * 100.0
        val displayPercent = rawPercent.roundToInt()
        val over = totalSpend > budget

        views.setTextViewText(R.id.widget_budget_total, "of " + formatCurrency(budget))

        // Threshold band drives both the segment fill and the pill styling.
        val band = when {
            rawPercent >= DANGER_AT -> Band.DANGER
            rawPercent >= WARN_AT -> Band.WARN
            else -> Band.OK
        }

        // Fill count is capped at the track length; any spend shows at least one
        // segment so the track never reads as empty when money has been spent.
        val ratio = (rawPercent / 100.0).coerceIn(0.0, 1.0)
        val filled = when {
            over -> SEGMENTS
            else -> (ratio * SEGMENTS).roundToInt()
                .coerceIn(if (totalSpend > 0) 1 else 0, SEGMENTS)
        }
        paintSegments(views, segmentIds, filled, band.segmentFill)

        views.setTextViewText(R.id.widget_percentage, "$displayPercent%")
        views.setInt(R.id.widget_percentage, "setBackgroundResource", band.pillBackground)
        views.setTextColor(
            R.id.widget_percentage,
            ContextCompat.getColor(context, band.pillText)
        )

        // Summary line: remaining budget when under, or the overspend when over.
        if (over) {
            val overBy = totalSpend - budget
            views.setTextViewText(
                R.id.widget_summary, formatCurrency(overBy) + " over budget"
            )
            views.setTextColor(
                R.id.widget_summary,
                ContextCompat.getColor(context, R.color.widget_budget_negative)
            )
        } else {
            val remaining = budget - totalSpend
            views.setTextViewText(
                R.id.widget_summary, formatCurrency(remaining) + " remaining this month"
            )
            views.setTextColor(
                R.id.widget_summary,
                ContextCompat.getColor(context, R.color.widget_text_secondary)
            )
        }
    }

    /** Renders the no-budget state: spend shown, idle track, "Set budget" CTA. */
    private fun renderNoBudget(
        context: Context,
        views: RemoteViews,
        segmentIds: IntArray
    ) {
        views.setTextViewText(R.id.widget_budget_total, "spent")
        paintSegments(views, segmentIds, filled = 0, fillDrawable = R.drawable.widget_seg_idle, emptyDrawable = R.drawable.widget_seg_idle)
        views.setTextViewText(R.id.widget_percentage, "Set budget")
        views.setInt(
            R.id.widget_percentage, "setBackgroundResource", R.drawable.widget_pill_primary
        )
        views.setTextColor(
            R.id.widget_percentage,
            ContextCompat.getColor(context, R.color.widget_on_primary)
        )
        views.setTextViewText(R.id.widget_summary, "Tap to set a monthly budget")
        views.setTextColor(
            R.id.widget_summary,
            ContextCompat.getColor(context, R.color.widget_text_secondary)
        )
    }

    /**
     * Sets the background of each segment: the first [filled] use [fillDrawable],
     * the rest use [emptyDrawable] (the track by default).
     */
    private fun paintSegments(
        views: RemoteViews,
        segmentIds: IntArray,
        filled: Int,
        fillDrawable: Int,
        emptyDrawable: Int = R.drawable.widget_seg_track
    ) {
        for (i in segmentIds.indices) {
            val id = segmentIds[i]
            if (id == 0) continue
            views.setInt(
                id, "setBackgroundResource",
                if (i < filled) fillDrawable else emptyDrawable
            )
        }
    }

    private fun renderFallback(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        segmentIds: IntArray
    ) {
        try {
            val fallback = RemoteViews(context.packageName, R.layout.spend_widget)
            fallback.setTextViewText(R.id.widget_month, currentMonthName())
            fallback.setTextViewText(R.id.widget_spent_amount, "\u20B90")
            fallback.setTextViewText(R.id.widget_budget_total, "spent")
            paintSegments(fallback, segmentIds, filled = 0, fillDrawable = R.drawable.widget_seg_idle, emptyDrawable = R.drawable.widget_seg_idle)
            fallback.setTextViewText(R.id.widget_percentage, "Set budget")
            fallback.setInt(
                R.id.widget_percentage, "setBackgroundResource", R.drawable.widget_pill_primary
            )
            fallback.setTextColor(
                R.id.widget_percentage,
                ContextCompat.getColor(context, R.color.widget_on_primary)
            )
            fallback.setTextViewText(R.id.widget_summary, "Tap to set a monthly budget")
            fallback.setTextColor(
                R.id.widget_summary,
                ContextCompat.getColor(context, R.color.widget_text_secondary)
            )
            appWidgetManager.updateAppWidget(appWidgetId, fallback)
        } catch (fallbackError: Exception) {
            Log.e(TAG, "Even fallback failed", fallbackError)
        }
    }

    private fun resolveSegmentIds(context: Context): IntArray {
        return IntArray(SEGMENTS) { i ->
            context.resources.getIdentifier(
                "widget_seg_$i", "id", context.packageName
            )
        }
    }

    private fun formatCurrency(amount: Double): String {
        return "\u20B9" + NumberFormat.getNumberInstance(Locale("en", "IN")).apply {
            maximumFractionDigits = 0
        }.format(amount)
    }

    /** Full month name for the current date, e.g. "August". Used as a fallback
     *  when Dart has not yet pushed the month (early cold start). */
    private fun currentMonthName(): String {
        return java.text.SimpleDateFormat("MMMM", Locale.ENGLISH).format(java.util.Date())
    }

    /** A spend threshold band and the resources that visualise it. */
    private enum class Band(
        val segmentFill: Int,
        val pillBackground: Int,
        val pillText: Int
    ) {
        OK(
            R.drawable.widget_seg_fill_ok,
            R.drawable.widget_pill_ok,
            R.color.widget_budget_positive
        ),
        WARN(
            R.drawable.widget_seg_fill_warn,
            R.drawable.widget_pill_warn,
            R.color.widget_on_warn
        ),
        DANGER(
            R.drawable.widget_seg_fill_danger,
            R.drawable.widget_pill_danger,
            R.color.widget_on_danger
        )
    }
}

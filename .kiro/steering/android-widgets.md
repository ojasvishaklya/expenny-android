---
inclusion: manual
description: Guide for adding new Android home screen widgets to the Expenny app
---

# Adding Android Home Screen Widgets to Expenny

This project uses the `home_widget` Flutter package for triggering widget updates from Flutter, and native Kotlin AppWidgetProviders that read data directly from the SQLite database.

## Architecture

There are two data flow patterns available:

### Pattern A: DB-Direct (Current — SpendWidgetProvider)

The provider reads the SQLite database directly on each `onUpdate()`. Flutter triggers updates via `HomeWidget.updateWidget()` on app resume, and the system also triggers periodic updates via `updatePeriodMillis`.

```
Flutter (trigger only)
    │
    ▼ HomeWidget.updateWidget(androidName: 'ProviderName') → fires APPWIDGET_UPDATE broadcast
    │
Native Android (read DB + render)
    │
    ▼ AppWidgetProvider.onUpdate() → opens SQLite DB → queries data → inflates RemoteViews
```

Best for: widgets that need fresh data from the transaction DB.

### Pattern B: SharedPreferences Bridge

Flutter computes data and writes key-value pairs to SharedPreferences via `HomeWidget.saveWidgetData()`. The provider reads SharedPreferences on update.

```
Flutter (compute + push data)
    │
    ▼ HomeWidget.saveWidgetData() → writes to SharedPreferences ("HomeWidgetPreferences")
    ▼ HomeWidget.updateWidget(androidName: 'ProviderName') → fires broadcast
    │
Native Android (read SharedPrefs + render)
    │
    ▼ AppWidgetProvider.onUpdate() → reads SharedPreferences → inflates RemoteViews
```

Best for: simple data that's already computed in Flutter (e.g., settings, preferences, cached values).

## Widget Refresh Strategy

Widgets refresh in two ways:

1. **System-triggered** — via `updatePeriodMillis` in the widget info XML (minimum 30 minutes). This is the fallback for when the app isn't open.

2. **App-triggered** — via `HomeWidget.updateWidget()` called from Flutter. In Expenny, this fires on every app resume using a `WidgetsBindingObserver` in `MyApp`:

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateHomeWidget();
    }
  }
}

void _updateHomeWidget() {
  try {
    HomeWidget.updateWidget(androidName: 'SpendWidgetProvider');
    // Add more widgets here as they're created:
    // HomeWidget.updateWidget(androidName: 'OtherWidgetProvider');
  } catch (_) {}
}
```

## Required Files Per Widget

For a widget called `{WidgetName}` (e.g., "BudgetWidget"):

### 1. Layout — `android/app/src/main/res/layout/{widget_name}.xml`

- Use only RemoteViews-compatible views: LinearLayout, RelativeLayout, FrameLayout, TextView, ImageView, Button, ProgressBar
- No RecyclerView, no custom views, no Jetpack Compose
- **No weighted spacer Views** — they crash in some launchers. Use `layout_marginTop` or `gravity` for spacing.
- Give the root container an id (e.g., `@+id/widget_container`) for tap handling
- Give each data TextView a unique id for programmatic text/color updates
- Reference `@color/` resources (not hardcoded hex) for theme support
- Use `@drawable/widget_background` for the root background (handles rounded corners + theme color)

### 2. Metadata — `android/app/src/main/res/xml/{widget_name}_info.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="{width}dp"
    android:minHeight="{height}dp"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/{widget_name}"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/{widget_name}_description" />
```

Size guide (dp to cells): 1 cell ≈ 70dp, 2 cells ≈ 110dp, 3 cells ≈ 180dp, 4 cells ≈ 250dp

### 3. Provider — `android/app/src/main/kotlin/com/ojasvishaklya/expenny/{WidgetName}Provider.kt`

Template for DB-direct pattern:

```kotlin
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

class {WidgetName}Provider : AppWidgetProvider() {

    companion object {
        private const val TAG = "{WidgetName}"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.{widget_name})

                // Query data from SQLite
                val data = queryData(context)

                // Set text/progress on views
                // views.setTextViewText(R.id.{view_id}, value)
                // views.setProgressBar(R.id.{progress_id}, max, progress, false)
                // views.setTextColor(R.id.{view_id}, ContextCompat.getColor(context, R.color.{color_name}))

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
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update widget $appWidgetId", e)
                // Push fallback so widget doesn't show "couldn't add"
                try {
                    val fallback = RemoteViews(context.packageName, R.layout.{widget_name})
                    // Set safe default text values
                    appWidgetManager.updateAppWidget(appWidgetId, fallback)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Even fallback failed", fallbackError)
                }
            }
        }
    }

    private fun queryData(context: Context): Double {
        try {
            val dbPath = context.getDatabasePath("transactions.db").absolutePath
            val dbFile = java.io.File(dbPath)
            if (!dbFile.exists()) return 0.0

            val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)
            // Run your query here
            // val cursor = db.rawQuery("SELECT ...", arrayOf(...))
            db.close()
        } catch (e: Exception) {
            Log.e(TAG, "DB query failed", e)
        }
        return 0.0
    }

    private fun formatCurrency(amount: Double): String {
        return "\u20B9" + NumberFormat.getNumberInstance(Locale("en", "IN")).apply {
            maximumFractionDigits = 0
        }.format(amount)
    }
}
```

### 4. Manifest — Add receiver in `android/app/src/main/AndroidManifest.xml`

Inside `<application>`, before the closing `</application>` tag:

```xml
<receiver
    android:name=".{WidgetName}Provider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/{widget_name}_info" />
</receiver>
```

### 5. String Resource — Add to `android/app/src/main/res/values/strings.xml`

```xml
<string name="{widget_name}_description">Description shown in widget picker</string>
```

### 6. Colors — Add to both `values/colors.xml` and `values-night/colors.xml`

Define widget-specific colors in both files for device theme support:

```xml
<!-- values/colors.xml (light) -->
<color name="{widget_name}_background">#FFFFFF</color>
<color name="{widget_name}_text_primary">#1C1B1F</color>

<!-- values-night/colors.xml (dark) -->
<color name="{widget_name}_background">#1E1E2E</color>
<color name="{widget_name}_text_primary">#E6E1E5</color>
```

### 7. Flutter Trigger — Register in `_updateHomeWidget()` in `lib/main.dart`

Add the new widget's provider name to the update function:

```dart
void _updateHomeWidget() {
  try {
    HomeWidget.updateWidget(androidName: 'SpendWidgetProvider');
    HomeWidget.updateWidget(androidName: '{WidgetName}Provider');  // ← add this
  } catch (_) {}
}
```

## Key Rules

1. **One provider class per widget type** — never multiplex widget types in a single provider
2. **Wrap entire onUpdate() in try-catch** — if the provider crashes, the launcher shows "couldn't add widget". Always push a fallback.
3. **Check DB file exists before opening** — fresh installs won't have `transactions.db` yet. Return defaults (e.g., ₹0) gracefully.
4. **Use FLAG_IMMUTABLE** on all PendingIntents (required for API 31+)
5. **No weighted spacer Views** — `View` with `layout_weight` in RemoteViews crashes some launchers. Use margins instead.
6. **Use `@color/` resource references** — enables automatic light/dark theming via `values/` and `values-night/` without Kotlin code
7. **Device theme, not app theme** — widgets follow system dark/light mode via Android resource qualifiers, independent of the app's internal theme toggle
8. **ProgressBar works in RemoteViews** — use `views.setProgressBar(id, max, progress, false)` for horizontal progress bars. Use a layer-list drawable for custom track/fill styling.
9. **Currency formatting** — use `NumberFormat.getNumberInstance(Locale("en", "IN"))` with ₹ prefix for Indian formatting
10. **Error handling** — always provide a fallback widget with safe defaults if the main update fails

## Existing Widgets

| Widget | Provider | Layout | Data Source | Refresh |
|--------|----------|--------|-------------|---------|
| Budget Tracker | SpendWidgetProvider | spend_widget.xml | SQLite direct query | 30min + app resume |

Update this table when adding new widgets.

## Checklist for New Widget

- [ ] Create layout XML in `res/layout/` (use `@color/` refs, no weighted spacers)
- [ ] Create drawable resources (background, progress drawables if needed)
- [ ] Create metadata XML in `res/xml/` (set updatePeriodMillis, resizeMode)
- [ ] Create Provider class in Kotlin source (with try-catch + fallback)
- [ ] Register receiver in AndroidManifest.xml
- [ ] Add description string to `res/values/strings.xml`
- [ ] Add color definitions to both `res/values/colors.xml` and `res/values-night/colors.xml`
- [ ] Register provider name in `_updateHomeWidget()` in `lib/main.dart`
- [ ] Test: add widget to home screen, verify data displays correctly
- [ ] Test: toggle device dark mode, verify widget theme switches
- [ ] Test: add a transaction, re-open app, verify widget updates
- [ ] Update the "Existing Widgets" table above

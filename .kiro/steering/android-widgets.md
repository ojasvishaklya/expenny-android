---
inclusion: manual
description: Guide for adding new Android home screen widgets to the Expenny app
---

# Adding Android Home Screen Widgets to Expenny

This project uses the `home_widget` Flutter package to bridge data from Flutter to native Android AppWidgets. Follow this pattern when creating new widgets.

## Architecture

```
Flutter (compute + push data)
    │
    ▼ HomeWidget.saveWidgetData() → writes to SharedPreferences
    ▼ HomeWidget.updateWidget(androidName: 'ProviderName') → triggers broadcast
    │
Native Android (read + render)
    │
    ▼ AppWidgetProvider.onUpdate() → reads SharedPreferences → inflates RemoteViews
```

## Required Files Per Widget

For a widget called `{WidgetName}` (e.g., "BudgetWidget"):

### 1. Layout — `android/app/src/main/res/layout/{widget_name}.xml`

- Use only RemoteViews-compatible views: LinearLayout, RelativeLayout, FrameLayout, TextView, ImageView, Button, ProgressBar
- No RecyclerView, no custom views, no Jetpack Compose
- Give the root container an id (e.g., `@+id/widget_container`) for tap handling
- Give each data TextView a unique id for programmatic text/color updates

### 2. Metadata — `android/app/src/main/res/xml/{widget_name}_info.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="{width}dp"
    android:minHeight="{height}dp"
    android:updatePeriodMillis="86400000"
    android:initialLayout="@layout/{widget_name}"
    android:resizeMode="none"
    android:widgetCategory="home_screen"
    android:description="@string/{widget_name}_description" />
```

Size guide (dp to cells): 1 cell ≈ 70dp, 2 cells ≈ 110dp, 3 cells ≈ 180dp, 4 cells ≈ 250dp

### 3. Provider — `android/app/src/main/kotlin/com/ojasvishaklya/expenny/{WidgetName}Provider.kt`

```kotlin
package com.ojasvishaklya.expenny

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent

class {WidgetName}Provider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.{widget_name})

            // Read data from SharedPreferences using namespaced keys
            // e.g., prefs.getString("{widget_name}_title", "Default")

            // Set text on views
            // views.setTextViewText(R.id.{view_id}, value)

            // Set tap-to-open intent
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

### 6. Flutter Service — Push data from Dart

```dart
import 'package:home_widget/home_widget.dart';

// Namespace all keys with widget name prefix to avoid collisions
await HomeWidget.saveWidgetData<String>('{widget_name}_key', value);
await HomeWidget.updateWidget(androidName: '{WidgetName}Provider');
```

## Key Rules

1. **One provider class per widget type** — never multiplex widget types in a single provider
2. **Namespace SharedPreferences keys** — prefix all keys with the widget name (e.g., `spend_widget_month`, `budget_widget_limit`)
3. **Keep providers thin** — providers only read SharedPrefs and inflate RemoteViews. All computation stays in Flutter.
4. **SharedPreferences file name is fixed** — always `"HomeWidgetPreferences"` (this is what the `home_widget` package writes to)
5. **Use FLAG_IMMUTABLE** on all PendingIntents (required for API 31+)
6. **Trigger updates from Flutter** — call `HomeWidget.updateWidget()` after saving data. The `updatePeriodMillis` in metadata is just a 24h fallback.
7. **Error handling** — wrap `HomeWidget.saveWidgetData` and `updateWidget` calls in try-catch on the Flutter side. If it fails, the widget retains its last displayed data.

## Existing Widgets

| Widget | Provider | Layout | Keys |
|--------|----------|--------|------|
| Monthly Spend | SpendWidgetProvider | spend_widget.xml | `widget_month`, `widget_amount`, `widget_is_dark` |

Update this table when adding new widgets.

## Checklist for New Widget

- [ ] Create layout XML in `res/layout/`
- [ ] Create metadata XML in `res/xml/`
- [ ] Create Provider class in Kotlin source
- [ ] Register receiver in AndroidManifest.xml
- [ ] Add description string to strings.xml
- [ ] Add Flutter-side data push logic (in WidgetService or dedicated service)
- [ ] Add trigger points (startup, data change, etc.)
- [ ] Test: add widget to home screen, verify data displays and tap opens app
- [ ] Update the "Existing Widgets" table above

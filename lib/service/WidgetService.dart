import 'package:home_widget/home_widget.dart';
import 'package:get/get.dart';

import '../controllers/TransactionController.dart';
import 'ConfigService.dart';

/// Bridges the app's config-and-budget state to the native Android home screen
/// widget using the "SharedPreferences bridge" pattern: Flutter computes both
/// the spend and the budget, pushes them into home_widget's shared prefs, then
/// asks the native provider to re-render.
///
/// Numbers are pushed as STRINGS. The installed home_widget (0.7.0+1) persists
/// a Dart double via putLong(Double.doubleToRawLongBits(..)) guarded by a
/// separate `home_widget.double.[key]` boolean flag, which is awkward and
/// version-specific to read back from a custom AppWidgetProvider. Storing the
/// values as strings and parsing them in Kotlin is robust across versions.
class WidgetService {
  // Keys shared with the native SpendWidgetProvider. Keep in sync.
  static const String keyMonth = 'widget_month';
  static const String keySpent = 'widget_spent';
  static const String keyBudget = 'widget_budget';

  static const String _androidProviderName = 'SpendWidgetProvider';

  // Sentinel string persisted when no budget is configured.
  static const String _unsetBudget = '-1';

  /// Recomputes spend + budget and pushes them to the native widget.
  ///
  /// Fire-and-forget: any failure (widget not placed, services not yet
  /// registered during early startup, platform channel unavailable) is
  /// swallowed so it can never block callers or crash the app.
  static Future<void> updateBudgetWidget() async {
    try {
      final double? budget = Get.isRegistered<ConfigService>()
          ? Get.find<ConfigService>().monthlyBudget.value
          : null;

      final double spend = Get.isRegistered<TransactionController>()
          ? Get.find<TransactionController>().expense.abs()
          : 0.0;

      final String monthName = _currentMonthName();

      await HomeWidget.saveWidgetData<String>(keyMonth, '$monthName BUDGET');
      await HomeWidget.saveWidgetData<String>(keySpent, spend.toString());
      await HomeWidget.saveWidgetData<String>(
        keyBudget,
        budget == null ? _unsetBudget : budget.toString(),
      );

      await HomeWidget.updateWidget(androidName: _androidProviderName);
    } catch (_) {
      // Swallow — widget may not be placed on the home screen, or services
      // may not be registered yet during cold start.
    }
  }

  /// Uppercase English month name for DateTime.now(), e.g. "JANUARY".
  static String _currentMonthName() {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[DateTime.now().month - 1];
  }
}

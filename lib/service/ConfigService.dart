import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'WidgetService.dart';

class ConfigService extends GetxController {
  final _storage = GetStorage();

  // --- Keys ---
  static const _keyDarkMode = 'isDarkMode';
  static const _keyLastSyncedAt = 'lastSyncedAt';
  static const _keyMonthlyBudget = 'monthlyBudget';

  // --- Reactive observables ---
  late final RxBool isDarkMode;
  late final Rx<String?> lastSyncedAt;
  late final Rx<double?> monthlyBudget;

  @override
  void onInit() {
    super.onInit();
    isDarkMode = RxBool(_storage.read<bool>(_keyDarkMode) ?? false);
    lastSyncedAt = Rx<String?>(_storage.read<String>(_keyLastSyncedAt));
    monthlyBudget = Rx<double?>(_storage.read<double>(_keyMonthlyBudget));
  }

  // --- Dark Mode ---
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Flips the current dark mode setting, persists it, and applies the theme
  /// change live via GetX.
  void toggleDarkMode() {
    final newValue = !isDarkMode.value;
    _storage.write(_keyDarkMode, newValue);
    isDarkMode.value = newValue;
    Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
  }

  // --- Last Synced At ---
  void setLastSyncedAt(String? value) {
    if (value == null) {
      _storage.remove(_keyLastSyncedAt);
    } else {
      _storage.write(_keyLastSyncedAt, value);
    }
    lastSyncedAt.value = value;
  }

  // --- Monthly Budget ---
  void setMonthlyBudget(double? value) {
    if (value == null) {
      _storage.remove(_keyMonthlyBudget);
    } else {
      _storage.write(_keyMonthlyBudget, value);
    }
    monthlyBudget.value = value;

    // Keep the home screen widget in sync with the new budget.
    // Fire-and-forget — do not await; failures are swallowed internally.
    WidgetService.updateBudgetWidget();
  }
}

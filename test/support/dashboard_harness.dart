import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:expenny/constants/color_schemes.g.dart';
import 'package:expenny/models/Transaction.dart';
import 'package:expenny/service/ConfigService.dart';

/// Shared harness for dashboard widget tests.
///
/// Rendering uses the application's own generated light and dark
/// [ColorScheme]s rather than Flutter defaults, so assertions about semantic
/// theme roles reflect what ships.

/// A narrow phone viewport, the smallest width the dashboard must support.
const Size kNarrowSurface = Size(320, 900);

/// A roomier viewport used to exercise the side-by-side layouts.
const Size kWideSurface = Size(480, 1000);

/// A tall viewport so a lazily-built list renders every dashboard section.
/// Without this, sections below the fold are never constructed and cannot be
/// asserted on.
const Size kTallSurface = Size(400, 2600);

/// Guards one-time GetStorage initialisation for the test process.
bool _storageReady = false;

ThemeData testLightTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
    );

ThemeData testDarkTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );

/// Wraps [child] in minimal material scaffolding.
///
/// [textScale] exposes hidden fixed-row assumptions; [dark] switches to the
/// application's dark scheme.
Widget wrapSection(
  Widget child, {
  bool dark = false,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: dark ? testDarkTheme() : testLightTheme(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Sets a fixed logical surface size for the duration of a test.
Future<void> setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Registers a [ConfigService] so widgets that observe the configured budget
/// can be pumped.
///
/// [monthlyBudget] seeds the budget; null leaves it unset.
///
/// GetStorage persists through path_provider, whose platform channel has no
/// implementation under flutter_test, so the channel is mocked to a fresh temp
/// directory. Each call uses its own container, so state cannot leak between
/// tests. No production code is modified.
/// Registers a [ConfigService] so widgets that observe the configured budget
/// can be pumped. The budget is left unset.
///
/// Seeding a budget is deliberately not offered: it would go through
/// `ConfigService.setMonthlyBudget`, which awaits `home_widget` platform
/// channels that never complete under `flutter_test` and hangs the run.
Future<ConfigService> registerConfigService() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // GetStorage persists through path_provider, whose platform channel has no
  // implementation under flutter_test. Mock it once and initialise a single
  // shared container; re-initialising per test re-enters the channel and is
  // needlessly fragile.
  if (!_storageReady) {
    final directory =
        await Directory.systemTemp.createTemp('expenny_dashboard');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => directory.path,
    );
    await GetStorage.init();
    _storageReady = true;
  }

  // Erase rather than recreate, so no budget leaks between tests.
  await GetStorage().erase();

  final service = Get.put(ConfigService());

  addTearDown(Get.reset);
  return service;
}

/// Builds an expense transaction. Expenses are stored with a negative amount,
/// mirroring `Transaction.setAmount`.
Transaction expenseTxn(
  double amount, {
  String tag = 'food',
  DateTime? date,
}) {
  return Transaction(
    date: date ?? DateTime(2026, 8, 15),
    amount: -amount.abs(),
    description: 'expense',
    isExpense: true,
    isStarred: false,
    tag: tag,
    paymentMethod: 'CASH',
  );
}

/// Builds an income transaction with a positive amount.
Transaction incomeTxn(
  double amount, {
  String tag = 'salary',
  DateTime? date,
}) {
  return Transaction(
    date: date ?? DateTime(2026, 8, 15),
    amount: amount.abs(),
    description: 'income',
    isExpense: false,
    isStarred: false,
    tag: tag,
    paymentMethod: 'CASH',
  );
}

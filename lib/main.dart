import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:expenny/constants/routes.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/service/SmsReaderService.dart';
import 'package:expenny/service/SmsParserService.dart';
import 'package:expenny/service/SmsSyncService.dart';
import 'package:expenny/service/ConfigService.dart';
import 'package:expenny/service/WidgetService.dart';

import 'constants/Theme.dart';
import 'controllers/TransactionController.dart';

void main() async {
  final transactionRepository =
      TransactionRepository(); // this updates transactions in the DB
  final transactionController = TransactionController(
      transactionRepository); // this updates transactions on the UI

  WidgetsFlutterBinding.ensureInitialized();

  await transactionRepository.open(); // this initializes the DB
  await GetStorage.init(); // this is my cache storage
  Get.put(ConfigService()); // Register config service before other controllers
  Get.put(transactionController); // Register controller to be used globally

  // Load the initial list before starting any sync. Awaiting here serialises
  // the two writers to transactionList, so a sync reload can never be
  // overwritten by a slower startup query.
  await transactionController.loadCurrentMonthTransactions();

  // Initialize SMS sync service
  final smsSyncService = SmsSyncService(
    smsReader: TelephonySmsReaderService(),
    smsParser: SmsParserService(),
    repository: transactionRepository,
    controller: transactionController,
  );
  Get.put(smsSyncService);

  // Auto-sync on startup (silent, no permission prompt). Awaited so the SMS
  // inserts and the sync-triggered reload complete before runApp(), otherwise
  // DashboardScreen's initial DB query can race ahead and show stale data.
  // Wrapped so permission/plugin/config/database failures never block launch.
  try {
    await smsSyncService.syncIfPermissionGranted();
  } catch (error, stackTrace) {
    developer.log(
      'Startup SMS sync failed; continuing app launch',
      name: 'expenny.startup',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Note: no explicit widget refresh here — loadCurrentMonthTransactions()
  // above already pushed one via refreshTransactionList() ->
  // WidgetService.updateBudgetWidget(). The WidgetsBindingObserver in MyApp
  // covers subsequent resumes.

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Fire-and-forget — widget update failure should never block resume.
      WidgetService.updateBudgetWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData(context),
      darkTheme: darkThemeData(context),
      themeMode: Get.find<ConfigService>().themeMode,
      initialRoute: RouteClass.home,
      getPages: RouteClass.routes,
    );
  }
}

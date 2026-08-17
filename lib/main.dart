import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:home_widget/home_widget.dart';
import 'package:expenny/constants/routes.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/service/ThemeService.dart';
import 'package:expenny/service/SmsReaderService.dart';
import 'package:expenny/service/SmsParserService.dart';
import 'package:expenny/service/SmsSyncService.dart';

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

  // Auto-sync on startup (silent, no permission prompt)
  smsSyncService.syncIfPermissionGranted();

  // Refresh home screen widget on cold start. The WidgetsBindingObserver in
  // MyApp also triggers on resume, but that doesn't fire on the very first
  // launch before the engine is fully attached.
  _updateHomeWidget();

  runApp(const MyApp());
}

/// Triggers the native widget provider's onUpdate() which reads fresh data
/// from the SQLite database. Fire-and-forget — widget update failure should
/// never block app startup.
void _updateHomeWidget() {
  try {
    HomeWidget.updateWidget(
      androidName: 'SpendWidgetProvider',
    );
  } catch (_) {
    // Silently fail — widget may not be placed on home screen
  }
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
      _updateHomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeService.getThemeMode(),
      initialRoute: RouteClass.home,
      getPages: RouteClass.routes,
    );
  }
}

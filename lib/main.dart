import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:expenny/constants/routes.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/service/ThemeService.dart';
import 'package:expenny/service/SmsReaderService.dart';
import 'package:expenny/service/SmsParserService.dart';

import 'constants/Theme.dart';
import 'controllers/TransactionController.dart';

/// Temporary debug function to verify SMS reading and parsing pipeline.
/// Will be replaced by SmsSyncService in a later task.
Future<void> _debugSmsPipeline() async {
  final smsReader = TelephonySmsReaderService();
  final smsParser = SmsParserService();

  debugPrint('[SMS Debug] Requesting permission...');
  final granted = await smsReader.requestPermission();
  if (!granted) {
    debugPrint('[SMS Debug] Permission denied');
    return;
  }

  // Use lastSyncedAt if available, otherwise default 3-month lookback
  final lastSyncedStr = GetStorage().read<String>('lastSyncedAt');
  final since = lastSyncedStr != null ? DateTime.parse(lastSyncedStr) : null;

  debugPrint('[SMS Debug] Reading inbox (since: ${since ?? "3 months ago"})...');
  final allSms = await smsReader.readInbox(since: since);
  debugPrint('[SMS Debug] Total SMS: ${allSms.length}');

  // Quick keyword pre-filter to skip OTPs, promos, delivery notifications etc.
  final keywords = RegExp(r'debit|credit|withdraw|deposit|transfer', caseSensitive: false);
  final candidates = allSms.where((sms) => keywords.hasMatch(sms.body)).toList();
  debugPrint('[SMS Debug] Candidates after keyword filter: ${candidates.length}');

  int parsed = 0;
  int unparsed = 0;

  for (final sms in candidates) {
    final result = smsParser.parse(sms.body);
    if (result != null) {
      parsed++;
    } else {
      unparsed++;
      debugPrint('[SMS Debug] UNPARSED: sender=${sms.sender} body=${sms.body}');
    }
  }

  debugPrint('[SMS Debug] Summary: parsed=$parsed, unparsed=$unparsed');
}

void main() async {
  final transactionRepository =
      TransactionRepository(); // this updates transactions in the DB
  final transactionController = TransactionController(
      transactionRepository); // this updates transactions on the UI

  WidgetsFlutterBinding.ensureInitialized();

  await transactionRepository.open(); // this initializes the DB
  await GetStorage.init(); // this is my cache storage
  Get.put(transactionController); // Register controller to be used globally

  // Temporary: trigger SMS debug pipeline
  _debugSmsPipeline();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

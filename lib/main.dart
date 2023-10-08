import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:expenny/constants/routes.dart';
import 'package:expenny/repository/TransactionRepository.dart';
import 'package:expenny/service/ThemeService.dart';

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
      initialRoute: RouteClass.welcome,
      getPages: RouteClass.routes,
    );
  }
}

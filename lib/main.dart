import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/service/ThemeService.dart';

import 'constants/Theme.dart';
import 'controllers/TransactionController.dart';

void main() async {
  await GetStorage.init();
  Get.put(TransactionController());

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

import 'package:get/get.dart';
import 'package:journal/screens/HomeScreen.dart';

import '../screens/CreateTransactionScreen.dart';

class RouteClass {
  static String home = '/';
  static String createTransaction = '/createTransaction';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.native,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: createTransaction,
      page: () => CreateTransactionScreen(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}

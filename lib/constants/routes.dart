import 'package:expenny/screens/WelcomeScreen.dart';
import 'package:get/get.dart';
import 'package:expenny/screens/HomeScreen.dart';

import '../screens/CreateTransactionScreen.dart';

class RouteClass {
  static String home = '/';
  static String createTransaction = '/createTransaction';
  static String welcome= '/welcome';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.native,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: createTransaction,
      page: () => CreateTransactionScreen(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: welcome,
      page: () => WelcomeScreen(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 1000),
    )
  ];
}

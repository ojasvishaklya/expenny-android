import 'package:flutter/material.dart';

import '../constants/routes.dart';
import '../widgets/LoadingWidget.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();

}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500), () {
      Get.offNamed(RouteClass.home);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
            ),
            LoadingWidget(animationName: 'welcome_screen_loader',size: 300,),
            Spacer(),
            Text('Expenny', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

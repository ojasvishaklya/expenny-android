import 'package:flutter/material.dart';
import 'package:journal/screens/HomeScreen.dart';

import 'constants/Theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkThemeData(context),
      home: HomeScreen(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:journal/screens/home_screen.dart';

import 'constants/theme.dart';

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


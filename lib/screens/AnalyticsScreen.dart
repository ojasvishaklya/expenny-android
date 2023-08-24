import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: const [
          Text(
            'Analytics Page',
            style: TextStyle(
              fontSize: 24,    // Adjust the font size as needed
              fontWeight: FontWeight.bold,   // Specify the font weight
            ),
          )
        ],
      );
  }
}

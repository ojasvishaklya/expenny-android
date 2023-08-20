import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/widgets/DisplayCard.dart';
import 'package:journal/widgets/TransactionCard.dart';

import '../controllers/TransactionController.dart';

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

import 'package:flutter/material.dart';

import '../widgets/ScreenHeaderWidget.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  const [
          ScreenHeaderWidget(text: 'Analytics'),
        ],
      ),
    );
  }
}

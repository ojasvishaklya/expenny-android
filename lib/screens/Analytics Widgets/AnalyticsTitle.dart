import 'package:flutter/material.dart';

class AnalyticsTitleWidget extends StatelessWidget {
  final String text;

  const AnalyticsTitleWidget({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(2.0), // Set the BorderRadius
      ),
      margin: EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
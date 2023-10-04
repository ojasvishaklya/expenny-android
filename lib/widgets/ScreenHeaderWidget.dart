import 'package:flutter/material.dart';

class ScreenHeaderWidget extends StatelessWidget {
  final String text;

  const ScreenHeaderWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context)
        .textTheme
        .apply(displayColor: Theme.of(context).colorScheme.onSurface);

    return Container(
      // margin: EdgeInsets.only(bottom: 32),
      child: Text(
        text,
        style: textTheme.headlineSmall,
      ),
    );
  }
}

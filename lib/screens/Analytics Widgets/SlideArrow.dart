import 'package:flutter/material.dart';

class SideArrowWidget extends StatelessWidget {
  const SideArrowWidget({
    Key? key,
    required this.shouldShow,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final bool shouldShow;
  final String text;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        padding: shouldShow == true ? EdgeInsets.all(8) : EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor, // Background color
          borderRadius: BorderRadius.circular(100), // Border radius
        ),
        child: shouldShow == true ? Center(child: Text(text)) : Container(),
      ),
    );
  }
}
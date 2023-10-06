import 'package:flutter/material.dart';

class PreferenceTileWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final onTap;

  const PreferenceTileWidget(
      {Key? key, required this.text, required this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // Make the border round
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 16.0),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
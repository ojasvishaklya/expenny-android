import 'package:flutter/material.dart';

class AlertContent extends StatelessWidget {
  const AlertContent({Key? key,
    required this.text,
    required this.showButtons,
    required this.onTap})
      : super(key: key);

  final String text;
  final bool showButtons;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, style: Theme
              .of(context)
              .textTheme
              .bodyLarge),
          showButtons == true ? SizedBox(height: 10.0) : Container(),
          // Add spacing between the message and buttons
          showButtons == true
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('cancel'),
              ),
              SizedBox(width: 16.0), // Add spacing between the buttons
              TextButton(
                onPressed: () {
                  onTap();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('delete'),
              ),
            ],
          )
              : Container(),
        ],
      ),
    );
  }
}

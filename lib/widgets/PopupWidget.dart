import 'package:flutter/material.dart';

void showSnackBar(
    {required BuildContext context,
    required String textContent,
    required Color color,
    int duration = 3}) {
  final snackBar = SnackBar(
    content: Text(textContent),
    duration: Duration(seconds: duration),
    backgroundColor: color,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showAlert({required BuildContext context, actions}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actions: actions,
      );
    },
  );
}

void showAlertContent({required BuildContext context, content}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: content,
      );
    },
  );
}

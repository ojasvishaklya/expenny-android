import 'package:flutter/material.dart';

void showSnackBar(
    {required BuildContext context,
    required String textContent,
    required Color color}) {
  final snackBar = SnackBar(
    content: Text(textContent),
    duration: Duration(seconds: 3),
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

import 'package:flutter/material.dart';

import '../models/Transaction.dart';

void showSnackBar(BuildContext context, String textContent, Color color) {
  final snackBar = SnackBar(
    content: Text(textContent),
    duration: Duration(seconds: 3),
    backgroundColor: color,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showAlert(BuildContext context, Transaction transaction, widgetList) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Transaction'),
        actions: widgetList,
      );
    },
  );
}

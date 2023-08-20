import 'package:flutter/material.dart';


Widget buildFloatingActionButton(function, label){
  return Align(
    alignment: Alignment.bottomCenter,
    child: ElevatedButton.icon(
      onPressed: function,
      icon: Icon(Icons.add),
      label: Text(label),
      style: ElevatedButton.styleFrom(),
    ),
  );
}

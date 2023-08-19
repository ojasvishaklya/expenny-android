import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:journal/constants/routes.dart';

import '../models/Transaction.dart';

Widget buildFloatingActionButton(function, label){
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: 40, // Set the desired height
      margin: EdgeInsets.only(bottom: 20), // Set the desired margin
      child: ElevatedButton.icon(
        onPressed: function,
        icon: Icon(Icons.add),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          // todo: color theme
        ),
      ),
    ),
  );
}

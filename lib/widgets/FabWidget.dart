import 'package:flutter/material.dart';

FloatingActionButton buildFloatingActionButton(function){
  return FloatingActionButton(
    onPressed: function,
    child: Icon(
      Icons.add,
      color: Colors.white,
    ),
  );
}

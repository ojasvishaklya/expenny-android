import 'package:flutter/material.dart';
import 'package:journal/constants/constants.dart';

AppBar buildAppBar(String pageName) {
  List<Widget> actions = [];
  if (pageName == homePage) {
    actions.add(IconButton(
      onPressed: () async {},
      icon: Icon(Icons.info_outline),
    ));
  }

  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

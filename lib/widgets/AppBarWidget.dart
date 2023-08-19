import 'package:flutter/material.dart';
import 'package:journal/constants/Constants.dart';
import 'package:journal/service/ThemeService.dart';

AppBar buildAppBar(String pageName) {
  List<Widget> actions = [];
  if (pageName == homePage) {
    actions.add(IconButton(
      onPressed: ()  {

        ThemeService.changeThemeMode();
      },
      icon: Icon(Icons.wb_sunny_rounded),
    ));
  }

  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

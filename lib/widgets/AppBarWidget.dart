import 'package:flutter/material.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/service/ThemeService.dart';

AppBar buildAppBar(String pageName) {
  List<Widget> actions = [];
  if (pageName == RouteClass.home) {
    actions.add(ThemeService.getThemeIconButton());
  }

  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

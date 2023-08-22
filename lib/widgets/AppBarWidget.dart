import 'package:flutter/material.dart';
import 'package:journal/constants/routes.dart';
import 'package:journal/service/ThemeService.dart';

AppBar buildAppBar() {
  List<Widget> actions = [];
    actions.add(ThemeService.getThemeIconButton());

  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

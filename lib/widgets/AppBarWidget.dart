import 'package:flutter/material.dart';

AppBar buildAppBar() {
  List<Widget> actions = [];
  // actions.add(ThemeService.getThemeIconButton());

  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

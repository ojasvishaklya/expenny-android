import 'package:flutter/material.dart';

AppBar buildAppBar({actions}) {
  return AppBar(
    actions: actions,
    automaticallyImplyLeading: true,
  );
}

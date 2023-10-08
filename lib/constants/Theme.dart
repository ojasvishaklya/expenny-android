import 'package:flutter/material.dart';

import 'color_schemes.g.dart';

ThemeData genericThemeData(colorScheme, context) {
  return ThemeData(
    useMaterial3: true,
    textTheme: TextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: colorScheme,
  );
}

// Our light/Primary Theme
ThemeData themeData(BuildContext context) {
  return genericThemeData(lightColorScheme, context);
}

// Dark Them
ThemeData darkThemeData(BuildContext context) {
  return genericThemeData(darkColorScheme, context);
}

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

// ColorScheme lightColorScheme = ColorScheme.light(
//   primary: Colors.blue,        // Define light mode primary color
//   primaryVariant: Colors.blue, // Define light mode primary variant color
//   secondary: Colors.orange,   // Define light mode secondary color
//   secondaryVariant: Colors.orange, // Define light mode secondary variant color
//   surface: Colors.white,      // Define light mode surface color
//   background: Colors.white,   // Define light mode background color
//   error: Colors.red,          // Define light mode error color
//   onPrimary: Colors.white,    // Define light mode text color on primary
//   onSecondary: Colors.black,  // Define light mode text color on secondary
//   onSurface: Colors.black,    // Define light mode text color on surface
//   onBackground: Colors.black, // Define light mode text color on background
//   onError: Colors.white,      // Define light mode text color on error
// );
//
// ColorScheme darkColorScheme = ColorScheme.dark(
//   primary: Colors.cyan,        // Define dark mode primary color
//   primaryVariant: Colors.blue, // Define dark mode primary variant color
//   secondary: Colors.orange,   // Define dark mode secondary color
//   secondaryVariant: Colors.orange, // Define dark mode secondary variant color
//   surface: Colors.grey[900]!, // Define dark mode surface color
//   background: Colors.grey[900]!, // Define dark mode background color
//   error: Colors.red,          // Define dark mode error color
//   onPrimary: Colors.white,    // Define dark mode text color on primary
//   onSecondary: Colors.black,  // Define dark mode text color on secondary
//   onSurface: Colors.white,    // Define dark mode text color on surface
//   onBackground: Colors.white, // Define dark mode text color on background
//   onError: Colors.white,      // Define dark mode text color on error
// );
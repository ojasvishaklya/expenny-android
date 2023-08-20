import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  static final _getStorage = GetStorage();
  static const darkModeKey = 'isDarkMode';

  static ThemeMode getThemeMode() {
    return getDarkThemeStatus() ? ThemeMode.dark : ThemeMode.light;
  }

  static bool getDarkThemeStatus() {
    return _getStorage.read(darkModeKey) ?? false;
  }

  static void setDarkThemeStatus(bool isDarkMode) {
    _getStorage.write(darkModeKey, isDarkMode);
  }

  static Widget getThemeIconButton() {
    Icon icon;
    Color color;
    if (getDarkThemeStatus()) {
      icon = Icon(Icons.wb_sunny_rounded);
    } else {
      icon = Icon(
        Icons.nightlight_round,
      );
    }

    return IconButton(
      onPressed: () {
        ThemeService.changeThemeMode();
      },
      icon: icon,
    );
  }

  static void changeThemeMode() {
    if (getDarkThemeStatus()) {
      setDarkThemeStatus(false);
      Get.changeThemeMode(ThemeMode.light);
    } else {
      setDarkThemeStatus(true);
      Get.changeThemeMode(ThemeMode.dark);
    }
  }
}

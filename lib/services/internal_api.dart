import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sushi_room/utils/globals.dart' as globals;

class InternalAPI {
  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkMode => prefs.getBool('isDarkMode') ?? false;
  bool get isDynamicTheme => prefs.getBool('isDynamicTheme') ?? false;

  set isDarkMode(bool value) => prefs.setBool('isDarkMode', value);
  set isDynamicTheme(bool value) => prefs.setBool('isDynamicTheme', value);

  Future<bool> isDynamicThemeSupported() async {
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 31;
    }
    return false;
  }

  void setDarkMode(bool value, BuildContext ctx) {
    String themeName = value ? 'dark' : 'light';
    isDynamicTheme ? themeName += 'Dynamic' : null;
    isDarkMode = value;

    ThemeSwitcher.of(ctx).changeTheme(
      theme: globals.allThemes[themeName]!,
      isReversed: !value,
    );
  }

  void setDynamicMode(bool value, BuildContext ctx) {
    String themeName = isDarkMode ? 'dark' : 'light';
    value ? themeName += 'Dynamic' : null;
    isDynamicTheme = value;

    ThemeSwitcher.of(ctx).changeTheme(
      theme: globals.allThemes[themeName]!,
    );
  }

  ThemeData getLastTheme() {
    String themeName = isDarkMode ? 'dark' : 'light';
    isDynamicTheme ? themeName += 'Dynamic' : null;

    return globals.allThemes[themeName]!;
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sushi_room/utils/globals.dart' as globals;
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class InternalAPI {
  late SharedPreferences prefs;
  static String repoLink = "https://github.com/SushiRoom/app";

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  bool get hasChangedUsername => prefs.getBool('hasChangedUsername') ?? false;
  bool get isDarkMode => prefs.getBool('isDarkMode') ?? true;
  bool get isDynamicTheme => prefs.getBool('isDynamicTheme') ?? false;
  String get currentUserName =>
      (prefs.getString('currentUserName') != null && prefs.getString('currentUserName')!.isNotEmpty) ? prefs.getString('currentUserName')! : 'TOTTI';

  set hasChangedUsername(bool value) => prefs.setBool('hasChangedUsername', value);
  set isDarkMode(bool value) => prefs.setBool('isDarkMode', value);
  set isDynamicTheme(bool value) => prefs.setBool('isDynamicTheme', value);
  set currentUserName(String value) => prefs.setString('currentUserName', value);

  Future<bool> isDynamicThemeSupported() async {
    if (Platform.isAndroid && !kIsWeb) {
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

  Future<bool> requestLocation() async {
    var res = await Permission.location.request();
    if (res.isDenied || res.isPermanentlyDenied) {
      await AppSettings.openAppSettings();
      res = await Permission.location.request();
    }
    return res.isGranted;
  }

  requestSnackBar({
    required String title,
    required void Function() onClick,
    required String subtitle,
    required String buttonText,
    required BuildContext context,
  }) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.snackbar(
      title,
      subtitle,
      onTap: (_) => onClick,
      mainButton: TextButton(
        onPressed: onClick,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: Text(buttonText),
      ),
      snackPosition: SnackPosition.BOTTOM,
      overlayBlur: 0,
      isDismissible: true,
      colorText: Theme.of(context).colorScheme.onError,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  Future<String> getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<String> getLatestVersion() async {
    var url = Uri.parse(
      "$repoLink/releases/latest",
    );

    try {
      var response = await http.get(url);
      var document = parse(response.body);
      var release = document.getElementsByTagName('h1').firstWhere((element) => element.text.startsWith("Release"));
      var version = release.text.replaceAll("Release ", "");

      return version;
    } catch (e) {
      return "";
    }
  }

  Future<String> getLatestVersionUrl() async {
    String version = await getLatestVersion();
    String url = "$repoLink/releases/download/$version/app-release.apk";

    return url;
  }
}

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/routes.dart';
import 'package:sushi_room/ui/pages/test.dart';

import 'package:sushi_room/utils/globals.dart' as globals;

class DynamicThemeBuilder extends StatefulWidget {
  final TestPage home;

  const DynamicThemeBuilder({
    super.key,
    required this.home,
  });

  @override
  State<DynamicThemeBuilder> createState() => _DynamicThemeBuilderState();
}

class _DynamicThemeBuilderState extends State<DynamicThemeBuilder> {
  InternalAPI internalAPI = Get.find<InternalAPI>();

  bool? dynamicSupported;

  initThings() async {
    dynamicSupported = await internalAPI.isDynamicThemeSupported();

    setState(() {});
  }

  @override
  void initState() {
    initThings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final ThemeData lightDynamicTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic?.harmonized(),
        );
        final ThemeData darkDynamicTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic?.harmonized(),
        );

        if (dynamicSupported != null && dynamicSupported!) {
          globals.allThemes['lightDynamic'] = lightDynamicTheme;
          globals.allThemes['darkDynamic'] = darkDynamicTheme;
        }

        return dynamicSupported != null
            ? ThemeProvider(
                initTheme: internalAPI.getLastTheme(),
                builder: (_, theme) => GetMaterialApp(
                  theme: theme,
                  initialRoute: RouteGenerator.testPageRoute,
                  onGenerateRoute: RouteGenerator.generateRoute,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    ...GlobalMaterialLocalizations.delegates,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('it'),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }
}

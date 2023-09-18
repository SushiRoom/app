import 'package:flutter/material.dart';
import 'package:sushi_room/ui/pages/home.dart';

class RouteGenerator {
  static const String mainPageRoute = '/';
  static const String testPageRoute = '/test';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    //ignore: unused_local_variable
    List? args = settings.arguments as List?;

    switch (settings.name) {
      case testPageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const TestPage(),
        );

      default:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const TestPage(),
        );
    }
  }
}

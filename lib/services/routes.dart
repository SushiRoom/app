import 'package:flutter/material.dart';
import 'package:sushi_room/ui/pages/home.dart';
import 'package:sushi_room/ui/pages/join.dart';
import 'package:sushi_room/ui/pages/create.dart';

class RouteGenerator {
  static const String homePageRoute = '/';
  static const String createPageRoute = '/create';
  static const String joinPageRoute = '/join';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    //ignore: unused_local_variable
    List? args = settings.arguments as List?;

    switch (settings.name) {
      case homePageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const HomePage(),
        );

      case createPageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const CreatePage(),
        );

      case joinPageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const JoinPage(),
        );

      default:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const HomePage(),
        );
    }
  }
}

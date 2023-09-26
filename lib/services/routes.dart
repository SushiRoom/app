import 'package:flutter/material.dart';
import 'package:sushi_room/ui/pages/home.dart';
import 'package:sushi_room/ui/pages/join.dart';
import 'package:sushi_room/ui/pages/create.dart';
import 'package:sushi_room/ui/pages/room/order.dart';
import 'package:sushi_room/ui/pages/room.dart';

class RouteGenerator {
  static const String homePageRoute = '/';
  static const String createPageRoute = '/create';
  static const String joinPageRoute = '/join';
  static const String roomPageRoute = '/room';
  static const String orderPageRoute = '/order';

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

      case roomPageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => RoomPage(
            roomId: args?[0] ?? "invalid",
          ),
        );

      case orderPageRoute:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => OrderPage(
            room: args?[0] ?? "invalid",
          ),
        );

      default:
        return MaterialPageRoute(
          settings: RouteSettings(name: settings.name),
          builder: (_) => const HomePage(),
        );
    }
  }
}

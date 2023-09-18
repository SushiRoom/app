import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/ui/pages/home.dart';
import 'package:sushi_room/ui/theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  InternalAPI internalAPI = InternalAPI();
  await internalAPI.init();
  Get.put(internalAPI);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.002),
    ),
  );
  runApp(const SushiRoom());
}

class SushiRoom extends StatelessWidget {
  const SushiRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicThemeBuilder(
      home: TestPage(),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/ui/theme/theme_manager.dart';
import 'package:sushi_room/firebase_options.dart';

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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously();
  runApp(const SushiRoom());
}

class SushiRoom extends StatelessWidget {
  const SushiRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicThemeBuilder();
  }
}

import 'dart:async';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/services/routes.dart';
import 'package:sushi_room/ui/components/update.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InternalAPI internalAPI = Get.find<InternalAPI>();
  RoomsAPI roomsAPI = RoomsAPI();

  bool isOffline = true;
  late StreamSubscription<InternetStatus> listener;

  checkAnyLeftRoom() async {
    List<Room> rooms;
    try {
      rooms = await roomsAPI.getRooms();
    } catch (e) {
      // no rooms
      return;
    }

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    for (var room in rooms) {
      if (room.users.any((u) => u.uid == currentUserId)) {
        Get.dialog(
          AlertDialog(
            title: I18nText('rejoinRoomDialog.title'),
            content: I18nText('rejoinRoomDialog.content'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  roomsAPI.removeUser(
                    room.id!,
                    Partecipant(
                      uid: currentUserId,
                      name: internalAPI.currentUserName,
                    ),
                  );
                },
                child: I18nText('rejoinRoomDialog.leave'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(
                    RouteGenerator.roomPageRoute,
                    arguments: [room.id],
                  );
                },
                child: I18nText('rejoinRoomDialog.ok'),
              ),
            ],
          ),
        );
      }
    }
  }

  setUpListener() {
    listener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          isOffline = false;
          break;
        case InternetStatus.disconnected:
          isOffline = true;
          break;
      }
      setState(() {});
    });
  }

  checkForUpdate(_) async {
    if (!Platform.isAndroid || kIsWeb) return;

    String latest = await internalAPI.getLatestVersion();
    String current = await internalAPI.getVersion();

    debugPrint("$latest $current");
    if (latest != "" && latest != current) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => OtaSheet(
            version: latest,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  void initState() {
    setUpListener();

    checkAnyLeftRoom();
    WidgetsBinding.instance.addPostFrameCallback(checkForUpdate);
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  Widget drawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: I18nText(
                'drawer.changeNameLabel',
                child: Text(
                  "",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  I18nText(
                    'drawer.greeting',
                    child: Text(
                      "",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: FlutterI18n.translate(context, 'drawer.nameLabel'),
                        suffixIcon: const Icon(Icons.edit),
                        border: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                      controller: TextEditingController(text: internalAPI.currentUserName),
                      onChanged: (value) {
                        internalAPI.currentUserName = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FutureBuilder(
              future: internalAPI.isDynamicThemeSupported(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        child: I18nText(
                          'drawer.themeLabel',
                          child: Text(
                            "",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: I18nText('drawer.dynamicThemeTitle'),
                        subtitle: I18nText('drawer.dynamicThemeDescription'),
                        trailing: ThemeSwitcher(
                          builder: (ctx) => Switch(
                            value: internalAPI.isDynamicTheme,
                            onChanged: (value) {
                              internalAPI.setDynamicMode(value, ctx);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      title: I18nText('home'),
      actions: [
        ThemeSwitcher(
          builder: (ctx) => InkWell(
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: const Offset(0.0, 0.0),
                  ).animate(anim);

                  final bounceAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(anim);

                  final fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(anim);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: ScaleTransition(
                      scale: bounceAnimation,
                      child: FadeTransition(
                        opacity: fadeAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: !internalAPI.isDarkMode
                    ? const Icon(
                        Icons.dark_mode,
                        key: ValueKey('dark'), // <-- senza key nva
                      )
                    : const Icon(
                        Icons.light_mode,
                        key: ValueKey('light'),
                      ),
              ),
              onPressed: () {
                internalAPI.setDarkMode(!internalAPI.isDarkMode, ctx);
              },
            ),
            onLongPress: () {
              Fluttertoast.showToast(msg: "#STAY FROG");
            },
          ),
        )
      ],
    );
  }

  Widget body() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SushiRoom",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFamily: GoogleFonts.manrope().fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: !isOffline
                        ? () {
                            Get.toNamed(RouteGenerator.joinPageRoute);
                          }
                        : null,
                    child: I18nText("joinRoomLabel"),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: !isOffline
                        ? () {
                            Get.toNamed(RouteGenerator.createPageRoute);
                          }
                        : null,
                    child: I18nText("createRoomLabel"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Made with",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextSpan(
                    text: " ❤️ ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  TextSpan(
                    text: "by ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextSpan(
                    text: "SushiRoom team",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: GoogleFonts.manrope().fontFamily,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse("https://github.com/SushiRoom"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: appBar(),
        drawer: drawer(),
        body: body(),
      ),
    );
  }
}

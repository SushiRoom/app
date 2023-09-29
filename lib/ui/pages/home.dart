import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InternalAPI internalAPI = Get.find<InternalAPI>();

  @override
  void initState() {
    super.initState();
  }

  Widget drawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Row(
                children: [
                  Text("Hi, ", style: Theme.of(context).textTheme.titleLarge),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Name",
                        suffixIcon: Icon(Icons.edit),
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
                  return ListTile(
                    subtitle: const Text("Use colors based on your phone"),
                    title: const Text("Dynamic Theme"),
                    trailing: ThemeSwitcher(
                      builder: (ctx) => Switch(
                        value: internalAPI.isDynamicTheme,
                        onChanged: (value) {
                          internalAPI.setDynamicMode(value, ctx);
                        },
                      ),
                    ),
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
      title: const Text('Home'),
      actions: [
        ThemeSwitcher(
          builder: (ctx) => IconButton(
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
        )
      ],
    );
  }

  Widget body() {
    return Center(
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
                onPressed: () {
                  Get.toNamed(RouteGenerator.joinPageRoute);
                },
                child: const Text("Join Room"),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {
                  Get.toNamed(RouteGenerator.createPageRoute);
                },
                child: const Text("Create Room"),
              ),
            ],
          ),
        ],
      ),
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

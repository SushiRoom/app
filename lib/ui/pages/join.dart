import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:animations/animations.dart';
import 'package:sushi_room/ui/pages/scan_code.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sushi_room/utils/globals.dart' as globals;

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final InternalAPI internalAPI = InternalAPI();

  PermissionStatus? hasLocationPermissions;
  bool? isLocationOn;
  LocationData? locationData;
  bool isLoading = true;

  Location location = Location();

  initLocationStuff() async {
    hasLocationPermissions = await location.hasPermission();
    isLocationOn = await location.serviceEnabled();
    if ((isLocationOn ?? false) && hasLocationPermissions == PermissionStatus.granted) {
      locationData = await location.getLocation();
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    initLocationStuff();
    super.initState();
  }

  Widget somethingIsMissingWidget({
    required String title,
    required String buttonText,
    void Function()? onPressed,
    Color? color,
  }) {
    color ??= Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: onPressed,
                  child: Row(
                    children: [
                      Text(buttonText),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> errors = [];
    if (hasLocationPermissions == PermissionStatus.denied || hasLocationPermissions == PermissionStatus.deniedForever) {
      errors.add(
        somethingIsMissingWidget(
          title: "We need location permissions to let you see rooms around you",
          buttonText: "Ask permissions",
          onPressed: () async {
            bool res = await internalAPI.requestLocation();
            if (res) {
              initLocationStuff();
              setState(() {
                isLoading = true;
              });
            }
          },
        ),
      );
    }

    if (!isLocationOn!) {
      errors.add(
        somethingIsMissingWidget(
          title: "To see rooms around you, we need your location to be turned on",
          buttonText: "Turn on",
          onPressed: () async {
            bool res = await location.requestService();
            if (res) {
              initLocationStuff();
              setState(() {
                isLoading = true;
              });
            }
          },
        ),
      );
    }

    return errors.isEmpty
        ? StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('rooms').onValue,
            builder: (context, snapshot) {
              var query = snapshot.data?.snapshot.children.where((element) {
                var data = element.value as Map<dynamic, dynamic>;
                if (data['usesLocation'] == true) {
                  var location = data['location'] as List<dynamic>;
                  var distance = sqrt(
                    pow(
                          double.parse(location[0]) - locationData!.latitude!,
                          2,
                        ) +
                        pow(
                          double.parse(location[1]) - locationData!.longitude!,
                          2,
                        ),
                  );
                  return distance <= 200;
                }
                return false;
              });
              if (query == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (query.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        globals.errorFaces[Random().nextInt(globals.errorFaces.length)],
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No rooms found nearby",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                );
              }

              debugPrint(query.toString());
              return SizedBox();
              // var rooms = query.map((e) => e.value as Map<String, dynamic>).toList();
            },
          )
        : Column(
            children: errors,
          );
  }

  Widget fab() {
    return OpenContainer(
      useRootNavigator: true,
      closedBuilder: (context, openContainer) {
        return FloatingActionButton(
          onPressed: openContainer,
          child: const Icon(Icons.qr_code_rounded),
        );
      },
      openBuilder: (context, closedContainer) {
        return const ScanCodePage();
      },
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(17),
        ),
      ),
      openColor: Theme.of(context).colorScheme.primaryContainer,
      closedColor: Theme.of(context).colorScheme.primaryContainer,
      middleColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Room'),
      ),
      body: body(),
      floatingActionButton: fab(),
    );
  }
}

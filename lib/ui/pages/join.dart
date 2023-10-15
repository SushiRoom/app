import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:animations/animations.dart';
import 'package:sushi_room/services/routes.dart';
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
    if ((hasLocationPermissions == PermissionStatus.denied || hasLocationPermissions == PermissionStatus.deniedForever) && !kIsWeb) {
      errors.add(
        somethingIsMissingWidget(
          title: FlutterI18n.translate(context, "joinRoomView.locationPermissionErrorTitle"),
          buttonText: FlutterI18n.translate(context, "joinRoomView.locationPermissionErrorBtnText"),
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

    if (!isLocationOn! || (kIsWeb && locationData == null)) {
      errors.add(
        somethingIsMissingWidget(
          title: FlutterI18n.translate(context, "joinRoomView.locationOffErrorTitle"),
          buttonText: FlutterI18n.translate(context, "joinRoomView.locationOffErrorBtnText"),
          onPressed: () async {
            if (!kIsWeb) {
              bool res = await location.requestService();
              if (res) {
                initLocationStuff();
                setState(() {
                  isLoading = true;
                });
              }
            } else {
              var data = await location.getLocation();
              setState(() {
                locationData = data;
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
                  return distance <= 0.5;
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
                      I18nText(
                        'joinRoomView.noNearbyRooms',
                        child: Text(
                          "",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: () {
                          Get.toNamed(RouteGenerator.createPageRoute);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            I18nText("joinRoomView.createRoomBtn"),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              List<Room> rooms = query.map((e) => e.value as Map<dynamic, dynamic>).map((e) => Room.fromJson(e)).toList();
              return ListView(
                children: [
                  for (var room in rooms) roomCard(room),
                ],
              );
            },
          )
        : Column(
            children: errors,
          );
  }

  Widget roomCard(Room room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        onTap: () {
          Get.toNamed(RouteGenerator.roomPageRoute, arguments: [room.id]);
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(17),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(room.name),
        subtitle: I18nText(
          "createdBy",
          translationParams: {
            "user": room.users.firstWhere((element) => element.uid == room.creator).name,
          },
        ),
        leading: room.password != null
            ? const Icon(
                Icons.lock,
                size: 20,
              )
            : const Icon(
                Icons.lock_open,
                size: 20,
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people,
              size: 20,
            ),
            const SizedBox(width: 5),
            Text(
              room.users.length.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fab() {
    return OpenContainer(
      useRootNavigator: true,
      closedBuilder: (context, openContainer) {
        return FloatingActionButton(
          heroTag: UniqueKey(),
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
        title: I18nText('joinRoomView.title'),
      ),
      body: body(),
      floatingActionButton: fab(),
    );
  }
}

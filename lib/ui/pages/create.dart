import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  RoomsAPI roomsAPI = RoomsAPI();
  InternalAPI internalAPI = Get.find<InternalAPI>();

  String uid = FirebaseAuth.instance.currentUser!.uid;

  // Room params
  String roomName = '';
  bool usesLocation = false;
  bool usesPassword = false;
  String password = '';
  List<String>? location;

  //location stuff
  bool? hasLocationPermissions;
  bool? isLocationOn;
  bool isLoading = true;

  final Location _location = Location();

  initLocationStuff() async {
    var temp = await _location.hasPermission();
    hasLocationPermissions = temp == PermissionStatus.granted || temp == PermissionStatus.deniedForever;
    isLocationOn = await _location.serviceEnabled();
  }

  @override
  void initState() {
    super.initState();
    initLocationStuff();
  }

  createNewRoom() async {
    Room room = Room(
      name: roomName,
      usesLocation: usesLocation,
      password: usesPassword ? password : null,
      creator: uid,
      location: location,
    );

    var roomId = await roomsAPI.createRoom(room);
    debugPrint('Room created with id: $roomId');

    Get.offAndToNamed('/room', arguments: [roomId]);
  }

  requestSnackBar({
    required String title,
    required void Function() onClick,
    required String subtitle,
    required String buttonText,
  }) {
    Get.snackbar(
      title,
      subtitle,
      onTap: (_) => onClick(),
      mainButton: TextButton(
        onPressed: onClick,
        child: Text(buttonText),
      ),
      snackPosition: SnackPosition.BOTTOM,
      overlayBlur: 0,
      isDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (String value) {
                setState(() {
                  roomName = value;
                });
              },
              // show me all possibles decoration objects
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                labelText: 'Room name',
                prefixIcon: Padding(padding: EdgeInsets.all(15), child: Icon(Icons.abc)),
              ),
            ),
            SwitchListTile(
              value: usesLocation,
              onChanged: (value) async {
                if (hasLocationPermissions!) {
                  if (isLocationOn!) {
                    setState(() {
                      usesLocation = value;
                      isLoading = true;
                    });
                    var locationData = await _location.getLocation();
                    location = [locationData.latitude.toString(), locationData.longitude.toString()];
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    requestSnackBar(
                      title: "You need to turn on location",
                      subtitle: "Click to turn on location",
                      buttonText: "Turn on",
                      onClick: () async {
                        bool res = await _location.requestService();
                        if (res) {
                          initLocationStuff();
                          setState(() {
                            usesLocation = hasLocationPermissions! && isLocationOn!;
                          });
                        }
                      },
                    );
                  }
                } else {
                  requestSnackBar(
                    title: "You need location permissions",
                    subtitle: "Click to ask permissions",
                    buttonText: "Ask",
                    onClick: () async {
                      bool res = await internalAPI.requestLocation();
                      if (res) {
                        initLocationStuff();
                        setState(() {
                          usesLocation = hasLocationPermissions! && isLocationOn!;
                        });
                      }
                    },
                  );
                }
              },
              secondary: usesLocation
                  ? isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.location_on_outlined)
                  : const Icon(Icons.location_off_outlined),
              //
              title: const Text("Use location"),
            ),
            SwitchListTile(
                value: usesPassword,
                onChanged: (value) {
                  setState(() {
                    usesPassword = value;
                    if (!usesPassword) {
                      password = '';
                    }
                  });
                },
                secondary: usesPassword ? const Icon(Icons.lock_outline) : const Icon(Icons.lock_open_outlined),
                title: const Text("Password")),
            usesPassword
                ? TextField(
                    onChanged: (String value) {
                      setState(() {
                        password = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Padding(padding: EdgeInsets.all(15), child: Icon(Icons.password)),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: roomName.isNotEmpty &&
                      ((usesPassword && password.isNotEmpty) || (!usesPassword)) &&
                      ((usesLocation && !isLoading) || (!usesLocation))
                  ? createNewRoom
                  : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

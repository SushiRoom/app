import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/services/routes.dart';

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

    Get.offAndToNamed(RouteGenerator.roomPageRoute, arguments: [roomId]);
  }

  requestSnackBar({
    required String title,
    required void Function() onClick,
    required String subtitle,
    required String buttonText,
  }) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.snackbar(
      title,
      subtitle,
      onTap: (_) => onClick,
      mainButton: TextButton(
        onPressed: onClick,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: Text(buttonText),
      ),
      snackPosition: SnackPosition.BOTTOM,
      overlayBlur: 0,
      isDismissible: true,
      colorText: Theme.of(context).colorScheme.onError,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText('createRoomView.title'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 20.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextField(
                onChanged: (String value) {
                  setState(() {
                    roomName = value;
                  });
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  labelText: FlutterI18n.translate(context, 'createRoomView.roomFormNameLabel'),
                  prefixIcon: const Padding(padding: EdgeInsets.all(15), child: Icon(Icons.abc)),
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
                        title: FlutterI18n.translate(context, 'createRoomView.locationOffErrorTitle'),
                        subtitle: FlutterI18n.translate(context, 'createRoomView.locationOffErrorDescription'),
                        buttonText: FlutterI18n.translate(context, 'createRoomView.locationOffErrorBtnText'),
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
                      title: FlutterI18n.translate(context, 'createRoomView.locationPermissionErrorTitle'),
                      subtitle: FlutterI18n.translate(context, 'createRoomView.locationPermissionErrorDescription'),
                      buttonText: FlutterI18n.translate(context, 'createRoomView.locationPermissionErrorBtnText'),
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
                title: I18nText("createRoomView.roomFormLocationSwitch"),
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
                title: I18nText("createRoomView.roomFormPwdSwitch"),
              ),
              usesPassword
                  ? TextField(
                      onChanged: (String value) {
                        setState(() {
                          password = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: FlutterI18n.translate(context, 'createRoomView.roomFormPwdLabel'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Padding(padding: EdgeInsets.all(15), child: Icon(Icons.password)),
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
                child: I18nText("createRoomView.roomFormCreateBtn"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

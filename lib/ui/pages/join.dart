import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:sushi_room/services/internal_api.dart';

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
      elevation: 2,
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
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // write longitude and latitude in a text
                Text(
                  'Longitude: ${locationData!.longitude}\nLatitude: ${locationData!.latitude}',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : Column(
            children: errors,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Room'),
      ),
      body: body(),
    );
  }
}
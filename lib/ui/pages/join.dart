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
    required Icon icon,
    void Function()? onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (hasLocationPermissions == PermissionStatus.denied || hasLocationPermissions == PermissionStatus.deniedForever) {
      return somethingIsMissingWidget(
        title: 'Location permissions are off',
        buttonText: 'Turn on location permissions',
        icon: const Icon(Icons.location_off_outlined),
        onPressed: () async {
          bool res = await internalAPI.requestLocation();
          if (res) {
            initLocationStuff();
            setState(() {
              isLoading = true;
            });
          }
        },
      );
    }

    if (!isLocationOn!) {
      return somethingIsMissingWidget(
        title: 'Location is off',
        buttonText: 'Turn on location',
        icon: const Icon(Icons.location_off_outlined),
        onPressed: () async {
          bool res = await location.requestService();
          if (res) {
            initLocationStuff();
            setState(() {
              isLoading = true;
            });
          }
        },
      );
    }

    if (locationData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
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

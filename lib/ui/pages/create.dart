import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  RoomsAPI roomsAPI = RoomsAPI();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  // Room params
  String roomName = '';
  bool usesLocation = false;
  bool usesPassword = false;
  String password = '';

  createNewRoom() async {
    if (roomName.isNotEmpty) {
      Room room = Room(
        name: roomName,
        usesLocation: usesLocation,
        password: usesPassword ? password : null,
        creator: uid,
      );

      var roomId = await roomsAPI.createRoom(room);
      debugPrint('Room created with id: $roomId');

      Get.toNamed('/room', arguments: [roomId]);
    } else {}
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
                onChanged: (value) {
                  setState(() {
                    usesLocation = value;
                  });
                },
                secondary: const Icon(Icons.location_on_outlined),
                title: const Text("Use location")),
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
            FilledButton(
              onPressed: roomName.isNotEmpty && ((usesPassword && password.isNotEmpty) || (!usesPassword)) ? createNewRoom : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

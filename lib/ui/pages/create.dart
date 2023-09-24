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

  createNewRoom() async {
    Room room = Room(
      name: 'Test Room',
      usesLocation: false,
      creator: uid,
    );

    var roomId = await roomsAPI.createRoom(room);
    debugPrint('Room created with id: $roomId');

    Get.toNamed('/room', arguments: [roomId]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new Room'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: createNewRoom,
          child: const Text('Create'),
        ),
      ),
    );
  }
}

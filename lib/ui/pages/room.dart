import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';

class RoomPage extends StatefulWidget {
  final String roomId;
  const RoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  RoomsAPI roomsAPI = RoomsAPI();
  InternalAPI internalAPI = Get.find<InternalAPI>();

  @override
  void initState() {
    addCurrentUser(widget.roomId);
    super.initState();
  }

  @override
  void dispose() {
    removeUser(
      widget.roomId,
      FirebaseAuth.instance.currentUser!.uid,
    );
    super.dispose();
  }

  removeUser(roomId, userId) async {
    Partecipant user = Partecipant(
      uid: userId,
      name: "",
    );

    await roomsAPI.removeUser(roomId, user);
  }

  addCurrentUser(roomId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String name = internalAPI.currentUserName;

    Partecipant user = Partecipant(
      uid: uid,
      name: name,
    );

    await roomsAPI.addUser(roomId, user);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Room"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Room"),
              Tab(text: "Order"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                QrImageView(
                  data: widget.roomId,
                  backgroundColor: Colors.white,
                  size: 90,
                ),
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('rooms')
                      .child(widget.roomId)
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> roomData =
                          (snapshot.data!.snapshot.value as Map)
                              .cast<String, dynamic>();
                      Room room = Room.fromJson(roomData);

                      return Column(
                        children: [
                          Text("Room name: ${room.name}"),
                          Text("Partecipants: ${room.users.length}"),
                          for (var user in room.users) Text(user.name),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
            Center(child: Text("La roba dei pesi")),
          ],
        ),

        // body: Column(
        //   children: [
        //     QrImageView(
        //       data: widget.roomId,
        //       backgroundColor: Colors.white,
        //       size: 90,
        //     ),
        //     StreamBuilder(
        //       stream: FirebaseDatabase.instance
        //           .ref()
        //           .child('rooms')
        //           .child(widget.roomId)
        //           .onValue,
        //       builder: (context, snapshot) {
        //         if (snapshot.hasData) {
        //           Map<String, dynamic> roomData =
        //               (snapshot.data!.snapshot.value as Map)
        //                   .cast<String, dynamic>();
        //           Room room = Room.fromJson(roomData);

        //           return Center(
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Text("Room name: ${room.name}"),
        //                 Text("Partecipants: ${room.users.length}"),
        //                 for (var user in room.users) Text(user.name),
        //               ],
        //             ),
        //           );
        //         } else {
        //           return const Center(
        //             child: CircularProgressIndicator(),
        //           );
        //         }
        //       },
        //     ),
        //   ],
        // ),
      ),
    );
  }
}

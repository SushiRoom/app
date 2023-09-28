import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sushi_room/models/room.dart';

class RoomLanding extends StatefulWidget {
  final String roomId;
  const RoomLanding({super.key, required this.roomId});

  @override
  State<RoomLanding> createState() => _RoomLandingState();
}

class _RoomLandingState extends State<RoomLanding> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        QrImageView(
          data: widget.roomId,
          backgroundColor: Colors.white,
          size: 90,
        ),
        TextButton(
          child: const Text("Copy room id"),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: widget.roomId),
            );
          },
        ),
        StreamBuilder(
          stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
              Room room = Room.fromJson(roomData);

              return Column(
                children: [
                  Card(
                    elevation: 1,
                    child: SizedBox(
                      height: 300,
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            for (var user in room.users)
                              ListTile(
                                // add icon
                                leading: const Icon(Icons.person),
                                title: Text(user.name),
                              ),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              onPressed: () => {},
                              label: const Text("Add user"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Text("Room name: ${room.name}"),
                  // Text("Partecipants: ${room.users.length}"),
                  // for (var user in room.users) Text(user.name),
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
    );
  }
}

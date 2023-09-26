import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sushi_room/models/room.dart';

class RoomLanding extends StatefulWidget {
  final String roomId;
  const RoomLanding({super.key, required this.roomId});

  @override
  State<RoomLanding> createState() => _RoomLandingState();
}

class _RoomLandingState extends State<RoomLanding>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

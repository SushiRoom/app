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

    return Scaffold(
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
                Room room = Room.fromJson(roomData);
                // Text("Table's plates: ${room.plates.length}"),
                // Text("Password? ${room.password != null ? "Yes" : "No"}"),
                // Text("Created by: ${room.users.firstWhere((element) => element.uid == room.creator).name}"),
                return Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                                child: ListTile(
                                  leading: room.password == null ? const Icon(Icons.lock_open) : const Icon(Icons.lock_outlined),
                                  title: Text("Owner: ${room.users.firstWhere((element) => element.uid == room.creator).name}"),
                                  subtitle: Text("Table's plates: ${room.plates.length}"),
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 1,
                      child: SizedBox(
                        height: 300,
                        width: 350,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListView(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  "Users",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              for (var user in room.users)
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(user.name),
                                  trailing: user.uid == room.creator
                                      ? const Icon(
                                          Icons.star_rounded,
                                        )
                                      : null,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 300,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "Scan to join the room",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      QrImageView(
                        data: widget.roomId,
                        backgroundColor: Colors.white,
                        size: 120,
                      ),
                      TextButton(
                        child: const Text("Copy room id"),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.roomId),
                          );
                        },
                      ),
                    ],
                  )),
                );
              })
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}

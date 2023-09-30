import 'dart:math';

import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/utils/globals.dart' as globals;

class FinalOrderPage extends StatefulWidget {
  final String roomId;
  final Partecipant currentUser;
  const FinalOrderPage({
    super.key,
    required this.roomId,
    required this.currentUser,
  });

  @override
  State<FinalOrderPage> createState() => _FinalOrderPageState();
}

class _FinalOrderPageState extends State<FinalOrderPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
            Room room = Room.fromJson(roomData);

            Map<String, int> plates = {};
            for (var plate in room.plates) {
              if (plate.number != "" && plate.quantity != "") {
                plates[plate.number] = (plates[plate.number] ?? 0) + int.parse(plate.quantity);
              }
            }

            return plates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          globals.errorFaces[Random().nextInt(globals.errorFaces.length)],
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No order yet",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                        for (var plateNumber in plates.keys)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: OpenContainer(
                              closedShape: const RoundedRectangleBorder(),
                              closedElevation: 0,
                              closedBuilder: (context, action) => Card(
                                margin: const EdgeInsets.only(left: 15, right: 15, top: 0),
                                child: ListTile(
                                  title: Text("$plateNumber x${plates[plateNumber]}"),
                                  trailing: Wrap(
                                    spacing: -17,
                                    children: [
                                      for (var plate in room.plates.where((plate) => plate.number == plateNumber).take(2))
                                        CircleAvatar(
                                          child: Text(plate.orderedBy.name[0]),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              openBuilder: (context, action) => Scaffold(
                                appBar: AppBar(
                                  title: const Text("Who ordered"),
                                ),
                                body: ListView(
                                  children: [
                                    for (var plate in room.plates.where((plate) => plate.number == plateNumber))
                                      Card(
                                        margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Text(plate.orderedBy.name[0]),
                                          ),
                                          title: Text(plate.orderedBy.name),
                                          subtitle: Text("x${plate.quantity}"),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              middleColor: Theme.of(context).colorScheme.background,
                              closedColor: Theme.of(context).colorScheme.background,
                              openColor: Theme.of(context).colorScheme.background,
                            ),
                          ),
                      ],
                    ),
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

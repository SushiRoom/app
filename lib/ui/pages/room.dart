import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/ui/components/hero_dialog.dart';
import 'package:sushi_room/ui/pages/room/final_order.dart';
import 'package:sushi_room/ui/pages/room/order.dart';
import 'package:sushi_room/ui/pages/room/room_landing.dart';

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

  bool passwordNeeded = true;

  List<Partecipant> localUsers = [];
  int currentUser = 0;

  String roomName = 'Loading...';

  @override
  void initState() {
    checkPassword();
    super.initState();
  }

  @override
  void dispose() {
    if (!passwordNeeded) {
      for (var element in localUsers) {
        removeUser(widget.roomId, element.uid);
      }
    }

    super.dispose();
  }

  Future<void> checkPassword() async {
    Room room = await roomsAPI.getRoom(widget.roomId);
    setState(() {
      roomName = room.name;
      passwordNeeded = room.password != null && room.creator != FirebaseAuth.instance.currentUser!.uid;
    });

    if (passwordNeeded) {
      String password = '';
      bool showText = false;
      Get.dialog(
        StatefulBuilder(
          builder: (context, localSetState) => AlertDialog(
            title: const Text("Insert room password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  obscureText: !showText,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    isDense: true,
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                CheckboxListTile(
                  title: const Text("Show password"),
                  value: showText,
                  onChanged: (value) {
                    localSetState(() {
                      showText = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(
                    closeOverlays: true,
                  );
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (password == room.password) {
                    Get.back();
                    addCurrentUser(widget.roomId);
                    setState(() {
                      passwordNeeded = false;
                    });
                  } else {
                    if (!Get.isSnackbarOpen) {
                      Get.snackbar(
                        "Wrong password",
                        "Please try again",
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      );
                    }
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      addCurrentUser(widget.roomId);
    }
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

    localUsers.add(user);
    await roomsAPI.addUser(roomId, user);
  }

  Widget customDialog() {
    return Hero(
      tag: 'a',
      child: StatefulBuilder(
        builder: (context, localSetState) => AlertDialog(
          title: const Text("Select user"),
          scrollable: true,
          content: Column(
            children: [
              SizedBox(
                width: 400,
                height: 150,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      for (Partecipant user in localUsers)
                        ListTile(
                          selected: localUsers.indexOf(user) == currentUser,
                          selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: CircleAvatar(
                            child: Text(
                              user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : "",
                            ),
                          ),
                          title: TextFormField(
                            initialValue: user.name,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Name',
                              isDense: true,
                            ),
                            readOnly: user.uid == FirebaseAuth.instance.currentUser!.uid,
                            onChanged: (value) {
                              user.name = value;
                              roomsAPI.updateUser(widget.roomId, user);
                              localSetState(() {});
                            },
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              if (user.uid != FirebaseAuth.instance.currentUser!.uid) {
                                removeUser(widget.roomId, user.uid);
                                localUsers.remove(user);
                                localSetState(() {});
                              }
                            },
                            icon: user.uid != FirebaseAuth.instance.currentUser!.uid ? const Icon(Icons.close) : const SizedBox.shrink(),
                          ),
                          onTap: user.name.isNotEmpty
                              ? () {
                                  currentUser = localUsers.indexOf(user);
                                  localSetState(() {});
                                  setState(() {});
                                  Get.back();
                                }
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: localUsers.any((element) => element.name.isEmpty)
                    ? null
                    : () {
                        Partecipant newUser = Partecipant(name: "");
                        localUsers.add(newUser);
                        roomsAPI.addUser(widget.roomId, newUser);
                        localSetState(() {});
                      },
                child: const Text("Add User"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget circleUserAvatar() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) {
              return customDialog();
            },
          ),
        );
      },
      child: Hero(
        tag: 'a',
        child: CircleAvatar(
          child: Text(
            localUsers[currentUser].name.substring(0, 1).toUpperCase(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Leave room"),
                  content: const Text("Are you sure you want to leave this room?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(closeOverlays: true);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
          ),
          title: Text(roomName),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Room"),
              Tab(text: "Order"),
              Tab(text: "Final Order"),
            ],
          ),
          actions: !passwordNeeded
              ? [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: circleUserAvatar(),
                  ),
                ]
              : null,
        ),
        body: !passwordNeeded
            ? StreamBuilder(
                stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
                    Room room = Room.fromJson(roomData);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!room.users.any((element) => element.uid == FirebaseAuth.instance.currentUser!.uid)) {
                        Get.back();
                      }
                    });

                    return TabBarView(
                      children: [
                        RoomLanding(
                          room: room,
                          currentUser: localUsers[currentUser],
                        ),
                        OrderPage(
                          room: room,
                          currentUser: localUsers[currentUser],
                        ),
                        FinalOrderPage(
                          room: room,
                          currentUser: localUsers[currentUser],
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            : null,
      ),
    );
  }
}

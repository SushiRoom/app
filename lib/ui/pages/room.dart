import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/services/routes.dart';
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

  String roomName = '';
  final ScrollController _scrollController = ScrollController();

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
            title: I18nText("roomView.pwdDialogTitle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  obscureText: !showText,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: FlutterI18n.translate(context, 'roomView.pwdDialogWrongPwdTitle'),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    password = value;
                  },
                ),
                CheckboxListTile(
                  title: I18nText("roomView.pwdDialogShowPwdLabel"),
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
                child: I18nText('cancel'),
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
                        FlutterI18n.translate(context, 'roomView.pwdDialogWrongPwdTitle'),
                        FlutterI18n.translate(context, 'roomView.pwdDialogWrongPwdMessage'),
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      );
                    }
                  }
                },
                child: I18nText('confirm'),
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
      tag: 'userAvatar',
      child: StatefulBuilder(
        builder: (context, localSetState) => AlertDialog(
          title: I18nText('roomView.userDialogTitle'),
          scrollable: true,
          content: Column(
            children: [
              SizedBox(
                width: 400,
                height: 300,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: localUsers.length,
                    itemBuilder: (context, index) {
                      Partecipant user = localUsers[index];
                      return Card(
                        elevation: 0,
                        color: Colors.transparent,
                        child: ListTile(
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
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: FlutterI18n.translate(context, 'roomView.userDialogUserNameLabel'),
                              isDense: true,
                            ),
                            focusNode: (index == localUsers.length - 1 && user.name.isEmpty) ? (FocusNode()..requestFocus()) : null,
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
                                if (user.uid == localUsers[currentUser].uid) {
                                  currentUser = 0;
                                }
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
                      );
                    },
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
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 200);
                      },
                child: I18nText('roomView.userDialogAddUserBtn'),
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
        tag: 'userAvatar',
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
                  title: I18nText("roomLeaveDialog.title"),
                  content: I18nText("roomLeaveDialog.message"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: I18nText("cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(closeOverlays: true);
                      },
                      child: I18nText("confirm"),
                    ),
                  ],
                ),
              );
            },
          ),
          title: Text(roomName),
          bottom: TabBar(
            tabs: [
              Tab(text: FlutterI18n.translate(context, 'roomView.roomTabLabel')),
              Tab(text: FlutterI18n.translate(context, 'roomView.orderTabLabel')),
              Tab(text: FlutterI18n.translate(context, 'roomView.finalOrderTabLabel')),
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
                        Get.offAllNamed(RouteGenerator.homePageRoute);
                        Get.snackbar(
                          FlutterI18n.translate(context, 'roomView.kickedFromRoomTitle'),
                          FlutterI18n.translate(context, 'roomView.kickedFromRoomMessage'),
                          snackPosition: SnackPosition.BOTTOM,
                          overlayBlur: 0,
                          isDismissible: true,
                          colorText: Theme.of(context).colorScheme.onError,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
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

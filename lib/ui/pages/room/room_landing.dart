import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';

class RoomLanding extends StatefulWidget {
  final Partecipant currentUser;
  final Room room;
  const RoomLanding({
    super.key,
    required this.currentUser,
    required this.room,
  });

  @override
  State<RoomLanding> createState() => _RoomLandingState();
}

class _RoomLandingState extends State<RoomLanding> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final RoomsAPI _roomsAPI = RoomsAPI();

  void requestSnackbar(
    String title,
    String description,
  ) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.snackbar(
      title,
      description,
      snackPosition: SnackPosition.BOTTOM,
      overlayBlur: 0,
      isDismissible: true,
      colorText: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  void showPwdDialog() {
    Get.dialog(
      AlertDialog(
        title: I18nText('roomView.pwdDialogPwdLabel'),
        content: ListTile(
          title: Text(widget.room.password!),
          trailing: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: widget.room.password!),
              );

              requestSnackbar(
                FlutterI18n.translate(context, 'roomView.QRCodeShareCopyPwd'),
                FlutterI18n.translate(context, 'roomView.QRCodeShareCopyPwdSuccess'),
              );
            },
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Get.back();
            },
            child: I18nText("ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Room room = widget.room;

    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: ListTile(
                            leading: room.password == null
                                ? const Icon(Icons.lock_open)
                                : IconButton(
                                    icon: Icon(
                                      Icons.lock_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () => showPwdDialog(),
                                  ),
                            title: I18nText(
                              "roomView.roomOwner",
                              translationParams: {
                                "user": room.users.firstWhere((element) => element.uid == room.creator, orElse: () => Partecipant(name: '')).name,
                              },
                            ),
                            subtitle: I18nText(
                              "roomView.roomPlatesCount",
                              translationParams: {
                                "count": room.plates.length.toString(),
                              },
                            ),
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
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: I18nText(
                            'roomView.usersCardLabel',
                            child: const Text(
                              "",
                              style: TextStyle(
                                fontSize: 15,
                              ),
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
                                : (user.uid != widget.currentUser.uid)
                                    ? InkWell(
                                        onTap: () {
                                          _roomsAPI.removeUser(
                                            widget.room.id!,
                                            user,
                                          );
                                        },
                                        child: const Icon(Icons.close),
                                      )
                                    : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: I18nText(
                          'roomView.QRCodeShareLabel',
                          child: const Text(
                            "",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      QrImageView(
                        data: widget.room.id!,
                        backgroundColor: Colors.white,
                        size: 120,
                      ),
                      TextButton(
                        child: I18nText("roomView.QRCodeShareCopyId"),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.room.id!),
                          );

                          requestSnackbar(
                            FlutterI18n.translate(context, 'roomView.QRCodeShareCopyId'),
                            FlutterI18n.translate(context, 'roomView.QRCodeShareCopyIdSuccess'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        },
        child: const Icon(Icons.share),
      ),
    );
  }
}

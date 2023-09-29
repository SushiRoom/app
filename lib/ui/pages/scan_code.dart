// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/services/routes.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  MobileScannerController controller = MobileScannerController();
  RoomsAPI roomsAPI = RoomsAPI();

  bool manualInput = false;
  TextEditingController textEditingController = TextEditingController();

  showDialog(Room room) {
    Get.dialog(
      AlertDialog(
        title: const Text('Room found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room name: ${room.name}"),
            Text("Password protected: ${room.password != null ? "Yes" : "No"}"),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Retry"),
          ),
          FilledButton(
            onPressed: () {
              controller.stop();
              Get.back();
              Get.offAndToNamed(RouteGenerator.roomPageRoute, arguments: [room.id]);
            },
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                manualInput = !manualInput;
                if (manualInput == true) {
                  controller.stop();
                } else {
                  controller.start();
                }
              });
            },
            icon: const Icon(Icons.keyboard),
          ),
        ],
      ),
      body: !manualInput
          ? MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                for (var element in capture.barcodes) {
                  if (element.format == BarcodeFormat.qrCode && element.rawValue != null) {
                    if (Get.isDialogOpen ?? false) {
                      return;
                    }

                    Room? room;
                    try {
                      room = await roomsAPI.getRoom(element.rawValue!);
                    } catch (e) {
                      return;
                    }

                    showDialog(room);
                  }
                }
              },
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Room code',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Room? room;
                      try {
                        room = await roomsAPI.getRoom(textEditingController.text);
                      } catch (e) {
                        if (!Get.isSnackbarOpen) {
                          Get.snackbar(
                            "Error",
                            "Room not found",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Theme.of(context).colorScheme.error,
                            colorText: Theme.of(context).colorScheme.onError,
                          );
                        }
                        return;
                      }

                      showDialog(room);
                    },
                    child: const Text("Join"),
                  ),
                ],
              ),
            ),
    );
  }
}

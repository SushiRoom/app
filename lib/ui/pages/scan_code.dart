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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MobileScanner(
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

              Get.dialog(
                AlertDialog(
                  title: const Text('Room found!'),
                  content: Column(
                    children: [
                      Text("Room name: ${room.name}"),
                      Text("Password protected: ${room.password != null}"),
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
                        Get.offAndToNamed(RouteGenerator.roomPageRoute, arguments: [element.rawValue]);
                      },
                      child: const Text("Join"),
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}

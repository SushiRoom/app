import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          for (var element in capture.barcodes) {
            if (element.format == BarcodeFormat.qrCode && element.rawValue != null) {
              if (Get.isDialogOpen ?? false) {
                return;
              }
              Get.dialog(
                AlertDialog(
                  title: const Text('Room found!'),
                  content: Text("Room ID: ${element.rawValue}"),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.stop();
                        Get.back();
                        Get.offAndToNamed('/room', arguments: [element.rawValue]);
                      },
                      icon: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
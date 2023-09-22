import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({super.key});

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: MobileScanner(
        onDetect: (barcodes) {
          barcodes.barcodes.forEach(
            (element) {
              debugPrint(element.displayValue);
            },
          );
        },
      ),
    );
  }
}

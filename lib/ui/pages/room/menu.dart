import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sushi_room/ui/components/extended_fab.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:universal_io/io.dart';
import 'package:sushi_room/utils/globals.dart' as globals;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_universal/webview_universal.dart' as web;

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  File? menu;

  bool isUrl = false;
  String url = '';

  WebViewController? webViewController;
  bool scanningCode = false;

  web.WebViewController? webWebViewController;

  MobileScannerController? qrScanController;

  void updateWebViewUrl(url) async {
    isUrl = true;
    webViewController?.loadRequest(
      Uri.parse(url),
    );

    if (kIsWeb) {
      if (webWebViewController!.is_init) {
        webWebViewController!.go(uri: Uri.parse(url));
      } else {
        webWebViewController!.init(
          context: context,
          setState: setState,
          uri: Uri.parse(url),
        );
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      webViewController = WebViewController()
        ..setJavaScriptMode(
          JavaScriptMode.unrestricted,
        );
    } else {
      webWebViewController = web.WebViewController();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool somethingOn = (menu == null && (url.isEmpty && !isUrl)) && !scanningCode;

    super.build(context);
    return Scaffold(
      body: somethingOn
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
                  I18nText(
                    'menuView.noMenu',
                    child: Text(
                      "",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                ],
              ),
            )
          : scanningCode
              ? MobileScanner(
                  controller: qrScanController,
                  onDetect: (capture) {
                    for (var element in capture.barcodes) {
                      if (element.format == BarcodeFormat.qrCode && element.rawValue != null) {
                        try {
                          Uri.parse(element.rawValue!);
                        } catch (e) {
                          debugPrint("Invalid url ${element.rawValue}");
                          return;
                        }

                        url = element.rawValue!;
                        isUrl = true;
                        scanningCode = false;
                        updateWebViewUrl(url);
                        qrScanController?.stop();

                        setState(() {});
                      }
                    }
                  },
                )
              : !isUrl
                  ? SfPdfViewer.file(
                      menu!,
                    )
                  : !kIsWeb
                      ? WebViewWidget(
                          controller: webViewController!,
                          gestureRecognizers: {}..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
                        )
                      : const Center(
                          child: Text("Menu is not supported on web yet :/"),
                        ),
      //
      floatingActionButton: somethingOn
          ? ExpandableFab(
              distance: 80,
              children: [
                ActionButton(
                  onPressed: () async {
                    //dialog promting for url
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          FlutterI18n.translate(context, 'menuView.title'),
                        ),
                        content: TextField(
                          onChanged: (value) {
                            url = value;
                          },
                          decoration: InputDecoration(
                            hintText: FlutterI18n.translate(context, 'menuView.urlHint'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              FlutterI18n.translate(context, 'cancel'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              updateWebViewUrl(url);
                              Navigator.pop(context);
                            },
                            child: Text(
                              FlutterI18n.translate(context, 'ok'),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.link),
                ),
                ActionButton(
                  onPressed: () {
                    scanningCode = true;
                    qrScanController = MobileScannerController();
                    setState(() {});
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                ActionButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      menu = File(result.files.single.path!);
                      setState(() {});
                    } else {
                      return;
                    }
                  },
                  icon: const Icon(Icons.file_open_outlined),
                ),
              ],
            )
          : FloatingActionButton(
              onPressed: () {
                menu = null;
                isUrl = false;
                url = '';

                scanningCode = false;
                qrScanController?.dispose();

                setState(() {});
              },
              child: const Icon(Icons.close),
            ),
    );
  }
}

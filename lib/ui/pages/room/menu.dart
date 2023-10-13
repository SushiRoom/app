import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sushi_room/ui/components/extended_fab.dart';
import 'package:universal_io/io.dart';
import 'package:sushi_room/utils/globals.dart' as globals;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: menu == null
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
          : PDFView(
              filePath: menu!.path,
              enableSwipe: true,
              autoSpacing: false,
              pageFling: true,
            ),
      floatingActionButton: menu == null
          ? ExpandableFab(
              distance: 80,
              children: [
                const ActionButton(
                  onPressed: null,
                  icon: Icon(Icons.link),
                ),
                const ActionButton(
                  onPressed: null,
                  icon: Icon(Icons.qr_code_scanner),
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
                setState(() {});
              },
              child: const Icon(Icons.close),
            ),
    );
  }
}

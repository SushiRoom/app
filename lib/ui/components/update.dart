import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:ota_update/ota_update.dart';
import 'package:sushi_room/services/internal_api.dart';
import 'package:sushi_room/ui/components/bouncing_text.dart';

class OtaSheet extends StatefulWidget {
  final String version;
  const OtaSheet({
    super.key,
    required this.version,
  });

  @override
  State<OtaSheet> createState() => _OtaSheetState();
}

class _OtaSheetState extends State<OtaSheet> {
  bool updating = false;
  var progress = 0;

  InternalAPI internalAPI = Get.find();

  startUpdate() async {
    String url = await internalAPI.getLatestVersionUrl();
    try {
      OtaUpdate().execute(url).listen(
          (OtaEvent event) {
            setState(() {
              progress = int.tryParse(event.value!) ?? progress;
            });
          },
          cancelOnError: true,
          onError: (e) {
            setState(() {
              updating = false;
            });
          });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: I18nText("updateDialog.title"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: updating
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: CircularProgressIndicator(
                                    value: progress / 100,
                                    strokeWidth: 8,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "$progress%",
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          I18nText("updateDialog.downloadingUpdate")
                        ],
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return BouncingDVD(
                            text: widget.version,
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                          );
                        },
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: updating
                    ? null
                    : () {
                        setState(() {
                          updating = true;
                        });
                        startUpdate();
                      },
                child: I18nText('updateDialog.updateBtn'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

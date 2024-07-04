import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/plate.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';
import 'package:sushi_room/ui/pages/room/final_order.dart';
import 'package:sushi_room/utils/globals.dart' as globals;

class OrderPage extends StatefulWidget {
  final Room room;
  final Partecipant currentUser;

  const OrderPage({
    super.key,
    required this.room,
    required this.currentUser,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with AutomaticKeepAliveClientMixin {
  RoomsAPI roomsAPI = RoomsAPI();
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _focusNodes = [];

  @override
  bool get wantKeepAlive => true;

  Widget addingWidget(Room room, bool active) {
    return FilledButton.tonal(
      onPressed: active
          ? () {
              Plate plate = Plate(
                arrived: false,
                number: '',
                orderedBy: widget.currentUser,
                quantity: '',
              );
              roomsAPI.addPlate(room, plate);

              if (room.plates.length > 1) {
                _scrollController.jumpTo(
                  _scrollController.position.maxScrollExtent + 100,
                );
              }

              setState(() {
                _focusNodes.add(FocusNode());
              });
              _focusNodes.last.requestFocus();
            }
          : null,
      child: I18nText("roomView.addPlateBtn"),
    );
  }

  Widget plateWidget({
    required Room room,
    required Plate plate,
    required List<Plate> userPlates,
  }) {
    Widget field(Widget child) => Flexible(
          child: Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: child,
              ),
            ),
          ),
        );

    return Row(
      key: Key("${plate.id!}_row"),
      children: [
        field(
          TextFormField(
            key: Key("${plate.id!}_num"),
            focusNode: _focusNodes[userPlates.indexWhere((element) => element.id == plate.id)],
            textInputAction: TextInputAction.next,
            initialValue: plate.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: FlutterI18n.translate(
                context,
                "roomView.plateNumberHint",
              ),
            ),
            maxLines: 1,
            onChanged: (text) {
              plate.number = text;
              roomsAPI.updatePlate(room, plate);
            },
          ),
        ),
        field(
          TextFormField(
            key: Key("${plate.id!}_qty"),
            keyboardType: TextInputType.number,
            initialValue: plate.quantity,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: FlutterI18n.translate(
                context,
                "roomView.plateQtyHint",
              ),
            ),
            maxLines: 1,
            onChanged: (text) {
              plate.quantity = text;
              roomsAPI.updatePlate(room, plate);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            _focusNodes.removeLast();
            roomsAPI.removePlate(room, plate);
          },
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget panel(Room room) {
    return Column(
      children: [
        const SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 18.0,
        ),
        I18nText(
          "roomView.finalOrderTabLabel",
          child: const Text(
            "",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 24.0,
            ),
          ),
        ),
        const SizedBox(
          height: 18.0,
        ),
        Expanded(
          child: FinalOrderPage(
            room: room,
            currentUser: widget.currentUser,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Room room = widget.room;
    List<Plate> userPlates = room.plates.where((element) => element.orderedBy.uid == widget.currentUser.uid).toList();
    userPlates.sort((a, b) => a.id!.compareTo(b.id!));

    if (userPlates.length > _focusNodes.length) {
      for (int i = _focusNodes.length; i < userPlates.length; i++) {
        _focusNodes.add(FocusNode());
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: userPlates.isEmpty
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
                            'roomView.noPlatesYet',
                            child: Text(
                              "",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          addingWidget(room, true)
                        ],
                      ),
                    )
                  : ListView(
                      key: Key(widget.currentUser.name),
                      controller: _scrollController,
                      children: [
                        for (Plate plate in userPlates)
                          plateWidget(
                            room: room,
                            plate: plate,
                            userPlates: userPlates,
                          ),
                        addingWidget(
                          room,
                          !userPlates.any(
                            (element) => element.number.isEmpty || element.quantity.isEmpty,
                          ),
                        ),
                        const SizedBox(
                          height: 70,
                        )
                      ],
                    ),
            ),
          ),
          KeyboardVisibilityBuilder(
            builder: (context, isKeyboardOpen) {
              return SlidingUpPanel(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                maxHeight: MediaQuery.of(context).size.height * 0.815,
                minHeight: isKeyboardOpen ? 0 : 90,
                panel: panel(room),
              );
            },
          ),
        ],
      ),
    );
  }
}

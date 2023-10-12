import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/plate.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';
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
  }) {
    Widget field(Widget child) => Flexible(
          child: Card(
            child: Center(
              child: child,
            ),
          ),
        );

    return Row(
      children: [
        field(
          TextFormField(
            focusNode: _focusNodes[room.plates.indexOf(plate)],
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
          onPressed: () => roomsAPI.removePlate(room, plate),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Room room = widget.room;
    List<Plate> userPlates = room.plates.where((element) => element.orderedBy.uid == widget.currentUser.uid).toList();

    return Scaffold(
      body: GestureDetector(
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
                      ),
                    addingWidget(
                      room,
                      !userPlates.any(
                        (element) => element.number.isEmpty || element.quantity.isEmpty,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

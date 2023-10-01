import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            }
          : null,
      child: const Text("Add plate"),
    );
  }

  Widget plateWidget(Room room, Plate plate) {
    Widget field(Widget child) => Flexible(
          child: AspectRatio(
            aspectRatio: 3.2,
            child: Card(
              child: Center(
                child: child,
              ),
            ),
          ),
        );

    return Row(
      children: [
        field(
          TextField(
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Plate number",
            ),
            maxLines: 1,
            onChanged: (text) {
              plate.number = text;
              roomsAPI.updatePlate(room, plate);
            },
          ),
        ),
        field(
          TextField(
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Quantity",
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
                      Text(
                        "You have no plates yet",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      addingWidget(room, true)
                    ],
                  ),
                )
              : ListView(
                  controller: _scrollController,
                  children: [
                    for (Plate plate in userPlates) plateWidget(room, plate),
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

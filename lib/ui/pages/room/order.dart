import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/plate.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/services/rooms_api.dart';

class OrderPage extends StatefulWidget {
  final String roomId;
  final Partecipant currentUser;

  const OrderPage({
    super.key,
    required this.roomId,
    required this.currentUser,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with AutomaticKeepAliveClientMixin {
  RoomsAPI roomsAPI = RoomsAPI();
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  Widget addingWidget(Room room, bool active) {
    return TextButton(
      onPressed: active
          ? () {
              Plate plate = Plate(
                arrived: false,
                number: '',
                orderedBy: widget.currentUser,
                quantity: '',
              );
              roomsAPI.addPlate(room, plate);
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
            controller: TextEditingController(text: plate.number),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Plate number",
            ),
            onChanged: (value) {
              plate.number = value;
              roomsAPI.updatePlate(room, plate);
            },
          ),
        ),
        field(
          TextField(
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            controller: TextEditingController(text: plate.quantity),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Quantity",
            ),
            onChanged: (value) {
              plate.quantity = value;
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

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder(
            stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
                Room room = Room.fromJson(roomData);

                List<Plate> userPlates = room.plates.where((plate) => plate.orderedBy.uid == widget.currentUser.uid).toList();

                return ListView(
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
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

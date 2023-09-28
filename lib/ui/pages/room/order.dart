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
  TextEditingController quantityController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  RoomsAPI roomsAPI = RoomsAPI();

  @override
  bool get wantKeepAlive => true;

  Widget addingWidget(Room room) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: TextField(
            controller: quantityController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(12),
              label: Text('Quantity'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Flexible(
          flex: 2,
          child: TextField(
            controller: plateController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(12),
              label: Text('Plate Number'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: (quantityController.text.isNotEmpty && plateController.text.isNotEmpty)
              ? () {
                  debugPrint(quantityController.text);
                  debugPrint(plateController.text);
                  roomsAPI.addPlate(
                    room,
                    Plate(
                      arrived: false,
                      quantity: quantityController.text,
                      number: plateController.text,
                      orderedBy: widget.currentUser,
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget plateWidget(Plate plate) {
    return Card(
      child: ListTile(
        title: Text(plate.quantity),
        subtitle: Text(plate.number),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.close_outlined),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref().child('rooms').child(widget.roomId).onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> roomData = (snapshot.data!.snapshot.value as Map).cast<String, dynamic>();
              Room room = Room.fromJson(roomData);

              return ListView(
                children: [
                  for (var plate in room.plates) plateWidget(plate),
                  Card(child: addingWidget(room)),
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
    );
  }
}

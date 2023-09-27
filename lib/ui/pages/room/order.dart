import 'package:flutter/material.dart';
import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/plate.dart';

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

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.currentUser.name),
      ),
    );
  }
}

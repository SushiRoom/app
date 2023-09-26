import 'package:flutter/material.dart';
import 'package:sushi_room/models/room.dart';

class OrderPage extends StatefulWidget {
  final Room room;
  const OrderPage({
    super.key,
    required this.room,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text("Order Page"),
      ),
    );
  }
}

import 'package:sushi_room/models/partecipant.dart';

class Plate {
  String? id;
  String quantity;
  String number;
  Partecipant orderedBy;
  bool arrived;

  Plate({
    this.id,
    required this.quantity,
    required this.number,
    required this.orderedBy,
    required this.arrived,
  });

  factory Plate.fromJson(Map<dynamic, dynamic> json) {
    return Plate(
      id: json['id'],
      quantity: json['quantity'],
      number: json['number'],
      orderedBy: Partecipant.fromJson(json['orderedBy']),
      arrived: json['arrived'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'number': number,
      'orderedBy': orderedBy.toJson(),
      'arrived': arrived,
    };
  }
}

import 'package:sushi_room/models/partecipant.dart';
import 'package:sushi_room/models/plate.dart';

class Room {
  String? id;
  String creator;
  List<Partecipant> users;
  List<Plate> plates;

  final String name;
  final bool usesLocation;
  final List<String>? location;
  final String? password;

  Room({
    this.id,
    required this.name,
    required this.usesLocation,
    this.location,
    this.password,
    required this.creator,
    this.users = const [],
    this.plates = const [],
  });

  factory Room.fromJson(Map<dynamic, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      usesLocation: json['usesLocation'],
      location: json['location'] != null ? (json['location'] as List).map((e) => e.toString()).toList() : [],
      password: json['password'],
      creator: json['creator'],
      users: json['users'] != null
          ? (json['users'] as Map<dynamic, dynamic>).map((key, value) => MapEntry(key, Partecipant.fromJson(value))).values.toList()
          : [],
      plates: json['plates'] != null
          ? (json['plates'] as Map<dynamic, dynamic>).map((key, value) => MapEntry(key, Plate.fromJson(value))).values.toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'usesLocation': usesLocation,
      'location': location,
      'password': password,
      'creator': creator,
      'users': users.asMap().map((key, value) => MapEntry(key.toString(), value.toJson())),
      'plates': plates.asMap().map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }
}

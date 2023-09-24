import 'package:firebase_database/firebase_database.dart';
import 'package:sushi_room/models/plate.dart';
import 'package:sushi_room/models/room.dart';
import 'package:sushi_room/models/partecipant.dart';

class RoomsAPI {
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref().child('rooms');

  Future<String> createRoom(Room room) async {
    final roomRef = _roomsRef.push();
    room.id = roomRef.key;

    await roomRef.set(room.toJson());
    return roomRef.key!;
  }

  Future<void> updateRoom(Room room) async {
    await _roomsRef.child(room.id!).update(room.toJson());
  }

  Future<void> deleteRoom(String roomId) async {
    await _roomsRef.child(roomId).remove();
  }

  Future<Room> getRoom(String roomId) async {
    DataSnapshot snapshot = await _roomsRef.child(roomId).get();
    Map<String, dynamic> roomData = (snapshot.value as Map).cast<String, dynamic>();

    return Room.fromJson(roomData);
  }

  Future<void> addUser(String roomId, Partecipant user) async {
    Room room = await getRoom(roomId);
    room.users.add(user);

    await updateRoom(room);
  }

  Future<void> removeUser(String roomId, Partecipant user) async {
    Room room = await getRoom(roomId);

    if (room.users.length > 1) {
      room.users.removeWhere((u) => u.uid == user.uid);
      await updateRoom(room);
    } else {
      await deleteRoom(room.id!);
    }
  }

  Future<void> addPlate(Room room, Plate plate) async {
    room.plates.add(plate);
    await updateRoom(room);
  }
}

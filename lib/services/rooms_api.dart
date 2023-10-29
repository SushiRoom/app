import 'dart:math';

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

    try {
      return Room.fromJson(roomData);
    } catch (e) {
      return Room.fromJson(roomData[roomId]);
    }
  }

  Future<List<Room>> getRooms() async {
    DataSnapshot snapshot = await _roomsRef.get();
    Map<String, dynamic> roomsData = (snapshot.value as Map).cast<String, dynamic>();

    List<Room> rooms = [];
    roomsData.forEach((key, value) {
      try {
        rooms.add(Room.fromJson(value));
      } catch (e) {
        rooms.add(Room.fromJson(value[key]));
      }
    });

    return rooms;
  }

  Future<Partecipant> addUser(String roomId, Partecipant user) async {
    user.uid ??= _roomsRef.push().key;

    Room room = await getRoom(roomId);
    room.users.add(user);

    await updateRoom(room);
    return user;
  }

  Future<void> removeUser(String roomId, Partecipant user) async {
    Room room = await getRoom(roomId);

    if (!room.users.any((element) => element.uid == user.uid)) return;
    if (room.users.where((e) => e.parent == null).length > 1) {
      room.users.removeWhere((u) => u.uid == user.uid || u.parent?.uid == user.uid);
      room.plates.removeWhere((p) => p.orderedBy.uid == user.uid || p.orderedBy.parent?.uid == user.uid);

      if (user.uid == room.creator) {
        var noChildUser = room.users.where((u) => u.parent == null).toList();
        room.creator = noChildUser[Random().nextInt(noChildUser.length)].uid!;
      }

      await updateRoom(room);
    } else {
      await deleteRoom(room.id!);
    }
  }

  Future<void> updateUser(String roomId, Partecipant user) async {
    Room room = await getRoom(roomId);

    room.users[room.users.indexWhere((u) => u.uid == user.uid)] = user;
    await updateRoom(room);
  }

  Future<void> addPlate(Room room, Plate plate) async {
    plate.id ??= _roomsRef.push().key;

    room.plates.add(plate);
    await updateRoom(room);
  }

  Future<void> removePlate(Room room, Plate plate) async {
    room.plates.removeWhere((p) => p.id == plate.id);
    await updateRoom(room);
  }

  Future<void> updatePlate(Room room, Plate plate) async {
    room.plates[room.plates.indexWhere((p) => p.id == plate.id)] = plate;
    await updateRoom(room);
  }
}

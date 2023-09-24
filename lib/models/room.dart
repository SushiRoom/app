class Room {
  final String id;
  final String name;
  final bool usesLocation;
  final List<String>? location;
  final String? password;

  Room({
    required this.id,
    required this.name,
    required this.usesLocation,
    this.location,
    this.password,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      usesLocation: json['usesLocation'],
      location: json['location'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'usesLocation': usesLocation,
      'location': location,
      'password': password,
    };
  }
}

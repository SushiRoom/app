class Partecipant {
  final String uid;
  final String name;

  Partecipant({
    required this.uid,
    required this.name,
  });

  factory Partecipant.fromJson(Map<dynamic, dynamic> json) {
    return Partecipant(
      uid: json['uid'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
    };
  }
}

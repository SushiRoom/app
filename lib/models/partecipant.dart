class Partecipant {
  String? uid;
  String name;

  Partecipant({
    this.uid,
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

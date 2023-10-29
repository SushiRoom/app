class Partecipant {
  String? uid;
  String name;
  Partecipant? parent;

  Partecipant({
    this.uid,
    required this.name,
    this.parent,
  });

  factory Partecipant.fromJson(Map<dynamic, dynamic> json) {
    return Partecipant(
      uid: json['uid'],
      name: json['name'],
      parent: json['parent'] != null ? Partecipant.fromJson(json['parent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'parent': parent != null ? parent!.toJson() : null,
    };
  }
}

class User {
  final String uid;
  final String name;

  User({
    required this.uid,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

class User {
  final int? id;
  final String email;
  final String username;
  final String? password;

  User({
    this.id,
    required this.email,
    required this.username,
    this.password,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'email': email,
      'username': username,
      'password': password,
    };
    if (id != null) map['id'] = id.toString();
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
    );
  }
}

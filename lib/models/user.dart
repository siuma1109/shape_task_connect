class User {
  final String email;
  final String username;
  final String password;

  User({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      username: map['username'],
      password: map['password'],
    );
  }
}

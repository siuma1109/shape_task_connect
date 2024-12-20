import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String displayName;
  final Timestamp createdAt;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      createdAt: map['created_at'],
    );
  }
}

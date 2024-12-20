import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class Comment {
  final String? id;
  final String taskId;
  final String userId;
  final String content;
  final Timestamp createdAt;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? photoPath;
  final User? user;

  Comment({
    this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    Timestamp? createdAt,
    this.latitude,
    this.longitude,
    this.address,
    this.photoPath,
    this.user,
  }) : createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'photo_path': photoPath,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      taskId: map['task_id'],
      userId: map['user_id'],
      content: map['content'],
      createdAt: map['created_at'] as Timestamp,
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      photoPath: map['photo_path'],
      user: map['user'] != null ? User.fromMap(map['user']) : null,
    );
  }
}

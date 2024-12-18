class Comment {
  final int? id;
  final int taskId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? address;

  Comment({
    this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    DateTime? createdAt,
    this.latitude,
    this.longitude,
    this.address,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    final map = {
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      userId: map['user_id'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      address: map['address'] as String?,
    );
  }
}

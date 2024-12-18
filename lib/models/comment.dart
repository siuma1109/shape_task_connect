class Comment {
  final int? id;
  final String taskId;
  final int userId;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      taskId: map['task_id'],
      userId: map['user_id'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}

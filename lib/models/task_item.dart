class TaskItem {
  final int id;
  final String title;
  final String description;
  final int createdBy;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
<<<<<<< HEAD
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
=======
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.millisecondsSinceEpoch,
>>>>>>> 3e1315a607208a29c8f9fb13fe65837df8dc7e86
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int,
<<<<<<< HEAD
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
=======
      title: map['title'],
      description: map['description'],
      createdBy: map['created_by'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
>>>>>>> 3e1315a607208a29c8f9fb13fe65837df8dc7e86
    );
  }
}

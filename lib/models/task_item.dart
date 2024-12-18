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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

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
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int,
      title: map['title'],
      description: map['description'],
      createdBy: map['created_by'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}

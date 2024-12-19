class TaskItem {
  final int? id;
  final String title;
  final String description;
  final int createdBy;
  final DateTime? createdAt;

  TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
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

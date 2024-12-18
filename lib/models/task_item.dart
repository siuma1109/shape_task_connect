class TaskItem {
  final String id;
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
}

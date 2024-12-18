class TaskItem {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String creatorName;
  final DateTime createdAt;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.creatorName,
    required this.createdAt,
  });
}

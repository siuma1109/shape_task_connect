import '../models/task_item.dart';

class DemoData {
  static List<TaskItem> generateTasks([int count = 10]) {
    return List.generate(
      count,
      (index) => TaskItem(
        id: 'task-$index',
        title: 'Complete Flutter Project ${index + 1}',
        description:
            'Finish the task management app ${index + 1} - looking for contributors!',
        createdBy: 'user-${index % 3}',
        creatorName: index % 2 == 0 ? 'John Doe' : 'Jane Smith',
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }
}

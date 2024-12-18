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
        createdBy: 1,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }
}

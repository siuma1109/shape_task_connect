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
        createdBy: index % 3,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }

  static List<Map<String, dynamic>> generateComments(String taskId,
      [int count = 3]) {
    return List.generate(
      count,
      (index) => {
        'task_id': taskId,
        'user_id': 1, // Using test user ID
        'content': 'This is comment ${index + 1} for task $taskId',
        'created_at': DateTime.now()
            .subtract(Duration(days: index))
            .millisecondsSinceEpoch,
      },
    );
  }
}

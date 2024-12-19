import '../models/task_item.dart';
import 'package:sqflite/sqflite.dart';

class DemoData {
  static Future<void> generateData(
    Transaction txn, {
    int userCount = 5,
    int tasksPerUser = 3,
    int commentsPerTask = 2,
    int collaboratorsPerTask = 2,
  }) async {
    final List<int> userIds = [];

    // Generate users
    for (int i = 1; i <= userCount; i++) {
      final userId = await txn.insert('users', {
        'email': 'user$i@example.com',
        'username': 'User $i',
        'password': 'password123',
      });
      userIds.add(userId);
    }

    // Generate tasks for each user
    for (int userId in userIds) {
      for (int i = 1; i <= tasksPerUser; i++) {
        // Create task
        final taskId = await txn.insert('tasks', {
          'title': 'Task $i by User $userId',
          'description': 'This is task number $i created by user $userId',
          'created_by': userId,
        });

        // Add creator as task participant
        await txn.insert('task_users', {
          'task_id': taskId,
          'user_id': userId,
        });

        // Add collaborators
        for (int j = 0; j < collaboratorsPerTask; j++) {
          // Get random user that isn't the creator
          final availableCollaborators =
              userIds.where((id) => id != userId).toList();
          if (availableCollaborators.isNotEmpty) {
            final collaboratorId =
                availableCollaborators[j % availableCollaborators.length];
            await txn.insert('task_users', {
              'task_id': taskId,
              'user_id': collaboratorId,
            });
          }
        }

        // Generate comments for this task
        for (int j = 1; j <= commentsPerTask; j++) {
          // Alternate between creator and collaborators for comments
          final commenterId = userIds[j % userIds.length];
          await txn.insert('comments', {
            'task_id': taskId,
            'user_id': commenterId,
            'content': 'Comment $j on Task $i',
            'latitude':
                j % 2 == 0 ? 40.7128 : 34.0522, // Alternate between NY and LA
            'longitude': j % 2 == 0 ? -74.0060 : -118.2437,
            'address': j % 2 == 0 ? 'New York, NY' : 'Los Angeles, CA',
          });
        }
      }
    }
  }

  static Future<void> clearAllData(Database db) async {
    await db.transaction((txn) async {
      await txn.delete('comments');
      await txn.delete('task_users');
      await txn.delete('tasks');
      await txn.delete('users');
    });
  }
}

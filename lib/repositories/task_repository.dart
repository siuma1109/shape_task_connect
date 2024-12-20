import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shape_task_connect/models/user.dart';
import '../models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tasksCollection = 'tasks';
  final String _taskUsersCollection = 'task_users';

  Future<String> createTask(Task task) async {
    final docRef =
        await _firestore.collection(_tasksCollection).add(task.toMap());
    return docRef.id;
  }

  Future<bool> joinTask(String taskId, String userId) async {
    try {
      await _firestore.collection(_taskUsersCollection).add({
        'task_id': taskId,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Task>> getAllTasks() async {
    final querySnapshot = await _firestore
        .collection(_tasksCollection)
        .orderBy('due_date', descending: true)
        .get();

    final tasks = <Task>[];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['completed'] = data['completed'] == 1;
      // Get user data
      if (data['created_by'] != null) {
        final userDoc =
            await _firestore.collection('users').doc(data['created_by']).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          data['user'] = User(
            uid: userDoc.id,
            email: userData['email'],
            displayName: userData['displayName'],
          ).toMap();
        }
      }

      tasks.add(Task.fromMap(data));
    }

    return tasks;
  }

  Future<Task?> getTask(String id) async {
    final doc = await _firestore.collection(_tasksCollection).doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;

    // Get user data
    if (data['created_by'] != null) {
      final userDoc =
          await _firestore.collection('users').doc(data['created_by']).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        data['user'] = {
          'uid': userDoc.id,
          'displayName': userData['displayName'],
          'email': userData['email'],
          'created_at': userData['created_at'],
        };
      }
    }

    return Task.fromMap(data);
  }

  Future<void> updateTask(Task task) async {
    await _firestore
        .collection(_tasksCollection)
        .doc(task.id.toString())
        .update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection(_tasksCollection).doc(id).delete();

    // Delete related task_users documents
    final querySnapshot = await _firestore
        .collection(_taskUsersCollection)
        .where('task_id', isEqualTo: id)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Task>> searchTasks(String keyword) async {
    final querySnapshot = await _firestore
        .collection(_tasksCollection)
        .where('title', isGreaterThanOrEqualTo: keyword)
        .where('title', isLessThan: keyword + '\uf8ff')
        .get();

    final tasks = <Task>[];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['completed'] = data['completed'] == 1;

      // Get user data
      final userDoc =
          await _firestore.collection('users').doc(data['created_by']).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        data['user'] = {
          'uid': userDoc.id,
          'displayName': userData['displayName'],
          'email': userData['email'],
          'createdAt': userData['created_at'],
        };
      }
      print('data: ${data.toString()}');
      tasks.add(Task.fromMap(data));
    }

    return tasks;
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    // Get tasks created by user
    final createdTasksQuery = await _firestore
        .collection(_tasksCollection)
        .where('created_by', isEqualTo: userId)
        .get();

    // Get tasks joined by user
    final joinedTasksQuery = await _firestore
        .collection(_taskUsersCollection)
        .where('user_id', isEqualTo: userId)
        .get();

    final joinedTaskIds = joinedTasksQuery.docs
        .map((doc) => doc.data()['task_id'] as String)
        .toList();

    final tasks = <Task>[];

    // Process created tasks
    for (var doc in createdTasksQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      data['completed'] = data['completed'] == 1;
      await _addUserDataToTask(data);
      tasks.add(Task.fromMap(data));
    }

    // Process joined tasks
    for (String taskId in joinedTaskIds) {
      final taskDoc =
          await _firestore.collection(_tasksCollection).doc(taskId).get();
      if (taskDoc.exists) {
        final data = taskDoc.data()!;
        data['id'] = taskDoc.id;
        data['completed'] = data['completed'] == 1;
        await _addUserDataToTask(data);
        tasks.add(Task.fromMap(data));
      }
    }

    return tasks;
  }

  Future<void> _addUserDataToTask(Map<String, dynamic> taskData) async {
    if (taskData['created_by'] != null) {
      final userDoc = await _firestore
          .collection('users')
          .doc(taskData['created_by'])
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        taskData['user'] = User(
          uid: userDoc.id,
          email: userData['email'],
          displayName: userData['displayName'],
          createdAt: userData['created_at'],
        ).toMap();
      }
    }
  }

  Future<bool> isUserJoined(String taskId, String userId) async {
    final querySnapshot = await _firestore
        .collection(_taskUsersCollection)
        .where('task_id', isEqualTo: taskId)
        .where('user_id', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> leaveTask(String taskId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_taskUsersCollection)
          .where('task_id', isEqualTo: taskId)
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Task>> getTasksByUserAndDueDateRange(
      String userId, Timestamp startDate, Timestamp endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('created_by', isEqualTo: userId)
          .where('due_date', isGreaterThanOrEqualTo: startDate)
          .where('due_date', isLessThanOrEqualTo: endDate)
          .get();

      return Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data();
        final userDoc =
            await _firestore.collection('users').doc(data['created_by']).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          data['user'] = User(
            uid: userDoc.id,
            email: userData['email'],
            displayName: userData['displayName'],
          );
        }

        return Task(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          createdBy: data['created_by'],
          createdAt: data['created_at'],
          dueDate: data['due_date'],
          completed: data['completed'] == 1,
          user: data['user'],
        );
      }).toList());
    } catch (e) {
      print('Error fetching tasks by date range: $e');
      return [];
    }
  }

  Future<Map<DateTime, int>> getTaskCountsByDateRange(
    String userId,
    Timestamp startDate,
    Timestamp endDate,
  ) async {
    try {
      final tasks =
          await getTasksByUserAndDueDateRange(userId, startDate, endDate);
      final taskCounts = <DateTime, int>{};

      for (final task in tasks) {
        // Convert Timestamp to DateTime for grouping
        final date = DateTime(
          task.dueDate.toDate().year,
          task.dueDate.toDate().month,
          task.dueDate.toDate().day,
        );
        taskCounts[date] = (taskCounts[date] ?? 0) + 1;
      }

      return taskCounts;
    } catch (e) {
      print('Error getting task counts by date range: $e');
      return {};
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shape_task_connect/models/user.dart';
import '../models/comment.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

  // Create
  Future<String> createComment(Comment comment) async {
    final docRef =
        await _firestore.collection(_collection).add(comment.toMap());
    return docRef.id;
  }

  // Read
  Future<List<Comment>> getCommentsByTask(String taskId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('task_id', isEqualTo: taskId)
        .orderBy('created_at', descending: true)
        .get();

    return Future.wait(querySnapshot.docs.map((doc) async {
      final data = doc.data();
      data['id'] = doc.id;

      // Get user data
      final userDoc = await _firestore
          .collection('users')
          .doc(data['user_id'].toString())
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        data['user'] = User(
          uid: userDoc.id,
          email: userData['email'],
          displayName: userData['displayName'],
        ).toMap();
      }

      return Comment.fromMap(data);
    }).toList());
  }

  Future<List<Comment>> getCommentsByUser(int userId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Comment.fromMap(data);
    }).toList();
  }

  Future<Comment?> getComment(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return Comment.fromMap(data);
  }

  // Update
  Future<void> updateComment(Comment comment) async {
    await _firestore.collection(_collection).doc(comment.id).update({
      'content': comment.content,
      'latitude': comment.latitude,
      'longitude': comment.longitude,
      'address': comment.address,
      'photo_path': comment.photoPath,
    });
  }

  // Delete
  Future<void> deleteComment(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Delete all comments for a task
  Future<void> deleteTaskComments(String taskId) async {
    final batch = _firestore.batch();
    final snapshots = await _firestore
        .collection(_collection)
        .where('task_id', isEqualTo: taskId)
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Count comments for a task
  Future<int> countTaskComments(String taskId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('task_id', isEqualTo: taskId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}

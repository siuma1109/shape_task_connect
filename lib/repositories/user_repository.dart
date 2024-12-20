import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shape_task_connect/models/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Create
  Future<bool> createUser(User user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
      return true;
    } catch (e) {
      print('Failed to create user: $e');
      return false;
    }
  }

  // Read
  Future<List<User>> getAllUsers() async {
    return _usersCollection.get().then((value) => value.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<User?> getUser(String id) async {
    final DocumentSnapshot doc = await _usersCollection.doc(id).get();
    if (!doc.exists) return null;
    return User.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<User?> getUserByEmail(String email) async {
    final QuerySnapshot snapshot =
        await _usersCollection.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data() as Map<String, dynamic>;

    return User(
      uid: snapshot.docs.first.id,
      email: data['email'],
      displayName: data['displayName'],
      createdAt: data['created_at'],
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final QuerySnapshot snapshot = await _usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return User.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  // Update
  Future<bool> updateUser(User user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete
  Future<bool> deleteUser(String id) async {
    try {
      // Delete user's tasks (you might want to handle this differently)
      final QuerySnapshot taskSnapshot = await _firestore
          .collection('tasks')
          .where('created_by', isEqualTo: id)
          .get();

      final batch = _firestore.batch();
      for (var doc in taskSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the user
      batch.delete(_usersCollection.doc(id));

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validation methods
  Future<bool> isEmailTaken(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // Search users by keyword (username or email)
  Future<List<User>> searchUsers(String keyword) async {
    final QuerySnapshot snapshot = await _usersCollection
        .where('displayName', isGreaterThanOrEqualTo: keyword)
        .where('displayName', isLessThan: keyword + '\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

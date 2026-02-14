
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String uid,
    required String name,
    required String age,
    required String email,
    required String role,

  }) async {
    try {
      await db.collection('users').doc(uid).set({
        'name': name,
        'age': age,
        'email': email,
        'role': role, 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
  print("Error saving user data: $e");
}

  }
  Future<String> getUserRole(String uid) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  return doc['role'];
}
}
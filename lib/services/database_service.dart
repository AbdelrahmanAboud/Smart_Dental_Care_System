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

      await db.runTransaction((transaction) async {
        
        DocumentReference statsRef = db.collection('metadata').doc('user_stats');
        DocumentSnapshot statsSnapshot = await transaction.get(statsRef);

        int newId = 100;
        if (statsSnapshot.exists) {
          newId = statsSnapshot['last_id'] + 1;
        }

        transaction.set(statsRef, {'last_id': newId}, SetOptions(merge: true));

        transaction.set(db.collection('users').doc(uid), {
          'name': name,
          'age': age,
          'email': email,
          'role': role,
          'id': newId.toString(), 
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc = await db.collection('users').doc(uid).get();
    return doc['role'];
  }
}
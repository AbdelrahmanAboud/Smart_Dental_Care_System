import 'dart:core';
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

  Future<void> addReview({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required int rating,
    required String comment,
  }) async {
    try {
      await db.collection('reviews').add({
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding review: $e");
      rethrow;
    }
  }
  Stream<QuerySnapshot> getMyReviews(String patientId) {
    return db
        .collection('reviews')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  // 1. حفظ حالة الـ Chart بالكامل أو سنة واحدة
  // حفظ حالة سنة معينة في ملف المريض
  Future<void> updateToothStatus({
    required String patientId,
    required int toothNumber,
    required String status,
    required String notes,
  }) async {
    try {
      await db.collection('patients').doc(patientId).set({
        'teeth_chart': {
          toothNumber.toString(): {
            'status': status,
            'notes': notes,
            'lastUpdate': FieldValue.serverTimestamp(),
          }
        }
      }, SetOptions(merge: true)); // merge: true عشان يحافظ على باقي السنان وميمسحهاش
    } catch (e) {
      print("Error updating tooth: $e");
    }
  }

  // جلب بيانات السنان للمريض بشكل لحظي
  Stream<DocumentSnapshot> getTeethStream(String patientId) {
    return db.collection('patients').doc(patientId).snapshots();
  }
}

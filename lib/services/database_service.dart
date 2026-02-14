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

        int newId = 1;
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
  // 1. وظيفة حفظ التقييم الجديد في فايربيز
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
        'createdAt': FieldValue.serverTimestamp(), // بيسجل وقت السيرفر بدقة
      });
    } catch (e) {
      print("Error adding review: $e");
      rethrow; // بنرمي الخطأ عشان الـ UI يحس بيه ويظهر رسالة للمستخدم
    }
  }

  // 2. وظيفة لجلب التقييمات الخاصة بدكتور معين بشكل لحظي
  Stream<QuerySnapshot> getMyReviews(String patientId) {
    return db
        .collection('reviews')
        .where('patientId', isEqualTo: patientId) // الفلترة باليوزر
        .orderBy('createdAt', descending: true)
        .snapshots();

  }
}

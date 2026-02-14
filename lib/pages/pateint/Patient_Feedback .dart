import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/PateintModels/Feedbaack_Rating.dart';
import 'package:smart_dental_care_system/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart';

class PatientFeedback extends StatefulWidget {
  @override
  State<PatientFeedback> createState() => _PatientFeedbackState();
}

class _PatientFeedbackState extends State<PatientFeedback> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);
  final TextEditingController _commentController = TextEditingController();
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    void _showSuccessDialog(BuildContext context) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.scale(
            scale: anim1.value,
            child: Opacity(
              opacity: anim1.value,
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(20),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBlue,
                        primaryBlue.withOpacity(0.1),
                        primaryBlue.withOpacity(0.05),
                        primaryBlue,
                      ],
                      stops: const [0.0, 0.4, 0.6, 1.0],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(29),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            size: 60,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "THANK YOU!",
                          style: TextStyle(
                            fontSize: 26,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.center,
                          "Your feedback helps us provide better dental care.",
                          style: TextStyle(
                            fontSize: 16,

                            color: primaryBlue.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryBlue, const Color(0xFF0099FF)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "DONE",
                                style: TextStyle(
                                  color: bgColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black),
        ),
        title: Text("Feedback & Rating", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage("lib/assets/doctor.jpeg"),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. Evelyn Reed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Orthodontist",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            Center(
              child: Column(
                children: [
                  Text(
                    "Rate Your Experience",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            SizedBox(height: 28),

            Text(
              "Your Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Share Your Experience in detail...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Text(
              "Past Reviews",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getMyReviews(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Something went wrong",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No reviews yet. Be the first!",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final data = reviews[index].data() as Map<String, dynamic>? ?? {};

                    // التعامل مع البيانات بأمان
                    final String doctorName = data['doctorName'] ?? "Anonymous";
                    final double rating = (data['rating'] != null)
                        ? (data['rating'] as num).toDouble()
                        : 0.0;
                    final String comment = data['comment'] ?? "";
                    final DateTime date = (data['createdAt'] != null && data['createdAt'] is Timestamp)
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.now();
                    final String formattedDate = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";



                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryBlue.withOpacity(0.2),
                                child: Text(
                                  doctorName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                radius: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctorName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                      (i) => Icon(
                                    i < rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            comment,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              elevation: 20,
              shadowColor: primaryBlue,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

              // استدعاء المكتبة فوق في الملف

// ... داخل الـ onPressed ...
              onPressed: () async {
                if (selectedRating > 0) {
                  try {
                    // 1. هات الـ UID بتاع المستخدم الحالي
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null){

                    // 2. روح هات الدوكيومنت بتاعه من جدول الـ users
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get();

                    // 3. اسحب الاسم من الدوكيومنت
                    String realName = "Patient"; // قيمة افتراضية
                    if (userDoc.exists && userDoc.data() != null) {
                      realName = userDoc.data()!['name'] ?? "Patient";
                    }

                    // 4. ابعت الريفيو بالاسم الحقيقي اللي جبناه من Firestore
                    await DatabaseService().addReview(
                      patientId: user!.uid,
                      patientName: realName, // الاسم اللي جه من الداتا بيز
                      doctorId: "D456",
                      doctorName: "Dr. Evelyn Reed",
                      rating: selectedRating,
                      comment: _commentController.text,
                    );
        _showSuccessDialog(context);

        // مسح النص بعد الإرسال بنجاح
        _commentController.clear();
        setState(() => selectedRating = 0);

        } else {
        // لو مفيش مستخدم مسجل دخول (حماية إضافية)
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first!")),
        );
        }
        } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
        );
        }
        } else {
        // إظهار SnackBar لو نسي يختار نجوم
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating! ⭐")),
        );
        }

        },
            child: Text(
              'Submit Feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class PatientFeedback extends StatefulWidget {
  const PatientFeedback({super.key});

  @override
  State<PatientFeedback> createState() => _PatientFeedbackState();
}

class _PatientFeedbackState extends State<PatientFeedback> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);
  final TextEditingController _commentController = TextEditingController();

  int selectedRating = 0;
  String? selectedDoctorId;
  String? selectedDoctorName;
  String? selectedDoctorRole;
  String? selectedDoctorImage;

  @override
  Widget build(BuildContext context) {
    final String currentPatientUid = FirebaseAuth.instance.currentUser!.uid;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // اطبعه هنا عشان تشوفه في الـ Debug Console
    print("DEBUG: Current User UID is -> $currentPatientUid");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Feedback & Rating", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Doctor from your Treatments",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // --- جلب الدكاترة بناءً على سجلات المريض في appointments ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patient_treatments') // تأكد من مطابقة الاسم هنا
                  .where('patientId', isEqualTo: currentPatientUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No treatment history found in patient_treatments.");
                }

                Map<String, String> doctorMap = {};
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  // ملاحظة هامة: إذا كان displayName فارغاً في Firebase Auth،
                  // يفضل جلب الاسم من كولكشن users كما فعلنا سابقاً.
                  String? dId = data['doctorId'];
                  String? dName = data['doctorName'] ?? "Doctor";

                  if (dId != null) {
                    doctorMap[dId] = dName!;
                  }
                }

                // ... كود الـ Dropdown المنتهي بـ items: doctorMap.entries.map ...
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: cardColor,
                      hint: const Text("Select your doctor", style: TextStyle(color: Colors.white54)),
                      value: selectedDoctorId,
                      isExpanded: true,
                      items: doctorMap.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        setState(() {
                          selectedDoctorId = val;
                          // هنا بنضيف السابقة قبل تخزين الاسم في المتغير
                          selectedDoctorName = "Dr. ${doctorMap[val]}";
                        });

                        // جلب البيانات بناءً على هيكلية الصورة (id, name, role)
                        var drDoc = await FirebaseFirestore.instance.collection('users').doc(val).get();
                        if (drDoc.exists) {
                          final drData = drDoc.data()!;
                          setState(() {
                            // استخدم 'role' بدلاً من 'specialization' بناءً على الصورة
                            selectedDoctorRole = drData['role'] ?? "Doctor";
                            // تأكد من وجود حقل 'profileImage' في الداتابيز أو استخدم افتراضي
                            selectedDoctorImage = drData['profileImage'] ?? "";
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            if (selectedDoctorId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: selectedDoctorImage != null && selectedDoctorImage!.isNotEmpty
                          ? NetworkImage(selectedDoctorImage!)
                          : const AssetImage("lib/assets/doctor.jpeg") as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedDoctorName!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text("Verified Treatment Access", style: TextStyle(color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // --- قسم التقييم بالنجوم ---
            Center(
              child: Column(
                children: [
                  const Text("Rate Your Experience", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- قسم التعليقات ---
            const Text("Your Comments", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Share details of your treatment...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
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
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () async {
              if (selectedDoctorId == null || selectedRating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a doctor and rating!")));
                return;
              }
              String? realpatientName;
              try {
                final patientDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get();

                if (patientDoc.exists) {
                  realpatientName = patientDoc.data()?['name']; // جلب الحقل اللي اسمه name
                }
              } catch (e) {
                debugPrint("Error fetching doctor name: $e");
              }
              // إرسال التقييم
              await DatabaseService().addReview(
                patientId: currentPatientUid,
                patientName: realpatientName ?? currentUser!.displayName ?? "Anonymous",
                doctorId: selectedDoctorId!,
                doctorName: selectedDoctorName!,
                rating: selectedRating,
                comment: _commentController.text,
              );

              Navigator.pop(context); // العودة بعد الإرسال
            },
            child: const Text('Submit Feedback', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
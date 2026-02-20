import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Traffic_Model.dart';

class ClinicTraffic extends StatefulWidget {
  @override
  State<ClinicTraffic> createState() => _ClinicTrafficState();
}

final Color bgColor = const Color(0xFF0B1C2D);
final Color cardColor = const Color(0xFF0F2235);
final Color primaryBlue = const Color(0xFF2EC4FF);

class _ClinicTrafficState extends State<ClinicTraffic> {
  // جلب المرضى فقط من كوليكشن users
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'Patient')
      .snapshots();
  Map<String, String> calculatePerformance(List<PatientModel> patients, List<QueryDocumentSnapshot> reviewsDocs) {
    double totalWaitMinutes = 0;
    int patientsWithStartTime = 0;

    double totalConsultMinutes = 0;
    int patientsDone = 0;

    // 1. حساب أوقات الانتظار والكشف
    for (var p in patients) {
      if (p.arrivedTime != null && p.consultationStart != null) {
        totalWaitMinutes += p.consultationStart!.difference(p.arrivedTime!).inMinutes.abs();
        patientsWithStartTime++;
      }

      if (p.consultationStart != null && p.consultationEnd != null) {
        totalConsultMinutes += p.consultationEnd!.difference(p.consultationStart!).inMinutes.abs();
        patientsDone++;
      }
    }

    // 2. حساب التقييم الحقيقي من كوليكشن الـ reviews
    double totalRating = 0;
    double averageRating = 0;

    if (reviewsDocs.isNotEmpty) {
      for (var doc in reviewsDocs) {
        var data = doc.data() as Map<String, dynamic>;
        print("Review found: ${data['rating']}"); // السطر ده هيعرفك الداتا مقروءة ولا لأ
        totalRating += (data['rating'] as num? ?? 0).toDouble();
      }
      averageRating = totalRating / reviewsDocs.length;
      print("Average calculated: $averageRating");
    }

    // حساب المتوسطات كـ نصوص
    String avgWait = patientsWithStartTime > 0
        ? "${(totalWaitMinutes / patientsWithStartTime).toStringAsFixed(1)} min"
        : "Pending...";

    String avgConsult = patientsDone > 0
        ? "${(totalConsultMinutes / patientsDone).toStringAsFixed(1)} min"
        : "Pending...";

    // 3. الـ Return النهائي (لازم يكون هنا في نهاية الدالة)
    return {
      "wait": avgWait,
      "consult": avgConsult,
      "rating": averageRating > 0
          ? "${averageRating.toStringAsFixed(1)}/5"
          : "5.0/5" // قيمة افتراضية لو مفيش ريفيوهات
    };
  }
  // دالة تحديث الحالة وتسجيل الوقت لحظة الضغط
  Future<void> _updatePatientFlow(String docId, String nextStatus) async {
    try {
      Map<String, dynamic> dataToUpdate = {'status': nextStatus};

      // تعديل السطر ده: لو رايح للانتظار سجل إنه وصل دلوقتي
      if (nextStatus == 'Waiting') dataToUpdate['arrivedTime'] = FieldValue.serverTimestamp();

      if (nextStatus == 'With Doctor') dataToUpdate['startTime'] = FieldValue.serverTimestamp();
      if (nextStatus == 'Done') dataToUpdate['endTime'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('users').doc(docId).update(dataToUpdate);
    } catch (e) {
      print("Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {

        if (snapshot.hasError) return const Scaffold(body: Center(child: Text("Connection Error")));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(backgroundColor: bgColor, body: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
        }

        final List<PatientModel> patients = snapshot.data!.docs.map((doc) {
          return PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        // حسابات الإحصائيات العلوية
        int total = patients.length;
        int completed = patients.where((p) => p.status == "Done").length;
        int waiting = patients.where((p) => p.status == "Waiting").length;
        int withDoctor = patients.where((p) => p.status == "With Doctor").length;
        int arrived = patients.where((p) => p.status == "Arrived").length;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Clinic Traffic", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(total, completed, total - completed),
                const SizedBox(height: 20),
                _buildStatsGrid(arrived, waiting, withDoctor, completed),
                const SizedBox(height: 20),

                // قائمة الكروت (Cards)
                // داخل الـ ListView.builder في كودك الحالي
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];

                    return FutureBuilder<QuerySnapshot>(
                      // هنجيب كل العلاجات عشان نتأكد هي شايفة المرضى ولا لأ
                      future: FirebaseFirestore.instance.collection('patient_treatments').get(),
                      builder: (context, treatmentSnapshot) {
                        String doctorName = "Not Assigned";

                        if (treatmentSnapshot.hasData) {
                          // البحث يدويًا داخل الداتا اللي رجعت
                          try {
                            final doc = treatmentSnapshot.data!.docs.firstWhere(
                                  (d) {
                                var data = d.data() as Map<String, dynamic>;
                                // بنجرب نقارن بكل الطرق الممكنة (كـ نص أو كـ مرجع)
                                var pId = data['patientId'];

                                if (pId is DocumentReference) {
                                  return pId.id == patient.id; // لو كان مرجع
                                }
                                return pId.toString().trim() == patient.id.trim(); // لو كان نص
                              },
                            );

                            var treatmentData = doc.data() as Map<String, dynamic>;
                            doctorName = treatmentData['doctorName'] ?? "No Name Field";
                            print("✅ أخيراً لقيناه! الدكتور: $doctorName");
                          } catch (e) {
                            // لو ملقاش حاجة في الـ firstWhere
                            print("❌ المريض ${patient.name} ملوش سجل في patient_treatments");
                          }
                        }

                        // الـ FutureBuilder التاني بتاع المواعيد بيكمل عادي هنا...
                        return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('appointments')
                              .where('patientId', isEqualTo: patient.id)
                              .limit(1)
                              .get(),
                          builder: (context, apptSnapshot) {
                            // ... (نفس كود المواعيد بتاعك) ...
                            String apptTime = "--:--";
                            if (apptSnapshot.hasData && apptSnapshot.data!.docs.isNotEmpty) {
                              var apptData = apptSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                              var rawTime = apptData['slot'];
                              apptTime = (rawTime is Timestamp) ? DateFormat('h:mm a').format(rawTime.toDate()) : rawTime.toString();
                            }

                            return _buildPatientCard(patient, doctorName, apptTime);
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              // داخل الـ build بعد تعريف List<PatientModel> patients

// انزل تحت عند استدعاء الـ Performance Section وغيره ليكون هكذا:
                // استبدل سطر استدعاء _buildPerformanceSection القديم بهذا الكود:
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('reviews').get(),
                  builder: (context, reviewSnapshot) {
                    // قائمة الريفيوهات (لو لسه بيحمل هتبقى فاضية)
                    List<QueryDocumentSnapshot> reviewsDocs = reviewSnapshot.data?.docs ?? [];

                    // مناداة الدالة بالـ 2 Arguments اللي محتاجاهم
                    var perfData = calculatePerformance(patients, reviewsDocs);

                    return _buildPerformanceSection(perfData);
                  },
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  // الكارت الخاص بالمريض (نفس تصميم الصورة)
  Widget _buildPatientCard(PatientModel patient, String realDoctor, String realApptTime) {
    Color statusColor = _getClr(patient.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الدائرة الجانبية مع الأيقونة
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                    ),
                  ),
                  Icon(
                    patient.status == 'Done' ? FontAwesomeIcons.check : FontAwesomeIcons.user,
                    color: statusColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(width: 15),
              // بيانات المريض
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(patient.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(patient.status, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Dr. $realDoctor", style: const TextStyle(color: Colors.white70, fontSize: 14)),                    // عرض الأوقات
                    // داخل دالة بناء الكارت
                    Row(
                      children: [
                        _timeTag("Appt: $realApptTime"), // وقت الحجز الحقيقي من Appointments
                        const SizedBox(width: 10),
                        // ابحث عن سطر _timeTag في دالة _buildPatientCard واستبدله بهذا:
                        _timeTag("Arr: ${patient.arrivedTime != null
                            ? DateFormat('h:mm a').format(patient.arrivedTime!)
                            : 'Not Arrived'}"), // وقت الوصول اللي بيتحدث بالزرار
                      ],
                    ),

                    if (patient.status == 'Done')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text("Completed Treatment", style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // زر الأكشن (يتغير حسب الحالة)
          _buildActionButtons(patient),
        ],
      ),
    );
  }

  Widget _timeTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    );
  }

  Widget _buildActionButtons(PatientModel patient) {
    if (patient.status == 'Arrived') {
      return _btn("Move to Waiting Room", Colors.teal, () => _updatePatientFlow(patient.id, "Waiting"));
    } else if (patient.status == 'Waiting') {
      return _btn("Notify Doctor", primaryBlue, () => _updatePatientFlow(patient.id, "With Doctor"));
    } else if (patient.status == 'With Doctor') {
      return _btn("Mark as Completed", Colors.green, () => _updatePatientFlow(patient.id, "Done"));
    }
    return const SizedBox.shrink();
  }

  Widget _btn(String txt, Color clr, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: clr, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: onTap,
        child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // المربعات الإحصائية بالأعلى
  Widget _buildStatsGrid(int arrived, int waiting, int doctor, int done) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statTile(Icons.person_pin_circle, Colors.amber, "$arrived", "Arrived"),
        _statTile(FontAwesomeIcons.clock, Colors.tealAccent, "$waiting", "Waiting"),
        _statTile(FontAwesomeIcons.userDoctor, primaryBlue, "$doctor", "In Clinic"),
        _statTile(Icons.check_circle, Colors.greenAccent, "$done", "Completed"),
      ],
    );
  }

  Widget _statTile(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeader(int total, int completed, int active) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text("Total Patients Today", style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text("$total", style: TextStyle(color: primaryBlue, fontSize: 45, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$completed completed", style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
              const SizedBox(width: 10),
              const Text("|", style: TextStyle(color: Colors.white10)),
              const SizedBox(width: 10),
              Text("$active active", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Clinic Performance",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _perfRow("Avg. Wait Time", data['wait']!, Colors.greenAccent),
          _perfRow("Avg. Consultation", data['consult']!, primaryBlue),
          _perfRow("Satisfaction", data['rating']!, Colors.amberAccent),
        ],
      ),
    );
  }

  Widget _perfRow(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Color _getClr(String s) {
    if (s == 'Done') return Colors.greenAccent;
    if (s == 'Waiting') return Colors.tealAccent;
    if (s == 'With Doctor') return primaryBlue;
    return Colors.orangeAccent;
  }
}

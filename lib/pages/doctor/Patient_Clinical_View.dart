import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:smart_dental_care_system/pages/doctor/Tooth_Chart.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class PatientClinicalView extends StatefulWidget {
  final String patientId;

  const PatientClinicalView({super.key, required this.patientId});

  @override
  State<PatientClinicalView> createState() => _PatientClinicalViewState();
}

class _PatientClinicalViewState extends State<PatientClinicalView> {

  // دالة رفع الصورة وتحديث Firestore
  Future<void> uploadAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // إظهار مؤشر تحميل (Loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
      ),
    );

    try {
      String cloudName = "ddrjzbrwp";
      String uploadPreset = "Smart Dental Care System";

      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.fields['upload_preset'] = uploadPreset;

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        String url = jsonResponse['secure_url'];

        // تحديث صورة المريض المختار
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.patientId)
            .update({"profileImage": url});

        if (mounted) Navigator.pop(context); // إخفاء الـ Loading
        print("Upload successful: $url");
      } else {
        if (mounted) Navigator.pop(context);
        print("Upload failed: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Connection error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Patient Profile",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // --- الجزء الأول: بيانات البروفايل (StreamBuilder لتحديث الصورة لحظياً) ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(widget.patientId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  String? profileUrl = userData['profileImage'];

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: uploadAndSaveImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryBlue.withOpacity(0.5), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: bgColor,
                                  backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                                      ? NetworkImage(profileUrl)
                                      : const AssetImage("lib/assets/profile.jpeg") as ImageProvider,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          userData['name'] ?? "Unknown Patient",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "ID: ${userData['id'] ?? 'N/A'}",
                          style: TextStyle(color: primaryBlue.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        _buildContactInfo(Icons.phone, userData['phone'] ?? "No Phone"),
                        const SizedBox(height: 8),
                        _buildContactInfo(Icons.email, userData['email'] ?? "No Email"),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // --- الجزء الثاني: جلب بيانات الرسم البياني للأسنان ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('patients').doc(widget.patientId).snapshots(),
                builder: (context, snapshot) {
                  Map<String, String> teethStates = {};

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    if (data.containsKey('teeth_chart')) {
                      var chart = data['teeth_chart'] as Map<String, dynamic>;
                      chart.forEach((key, value) {
                        teethStates[key] = value['status'] ?? "none";
                      });
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Interactive Dental Chart", style: TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 15),
                        const Text("Upper Jaw", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 1; i <= 16; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Uppertooth(i, teethStates[i.toString()] ?? "none"),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text("Low Jaw", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 17; i <= 32; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Lowertooth(i, teethStates[i.toString()] ?? "none"),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLegend(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Toothchart(patientId: widget.patientId),
                                ));
                              },
                              child: Text("View Detailed Chart", style: TextStyle(color: primaryBlue)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- أزرار الإجراءات ---
              _buildActionButton("Start New Treatment", primaryBlue, Colors.black, () {
                // Future treatment plan integration
              }),

              const SizedBox(height: 12),

              _buildActionButton("View Records", Colors.transparent, primaryBlue, () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PatientRecord(),
                ));
              }, isOutlined: true),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],

    );
  }

  Widget _buildActionButton(String title, Color bg, Color text, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isOutlined
          ? OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: bg, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        child: Text(title, style: TextStyle(fontSize: 16, color: text, fontWeight: FontWeight.bold)),
      )
          : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        child: Text(title, style: TextStyle(fontSize: 16, color: text, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem("Cavity", const Color(0xFFFF4D6D)),
            _legendItem("Filling", const Color(0xFF00E5FF)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem("Crown", const Color(0xFFFFC300)),
            _legendItem("Healthy", const Color(0xFF06D6A0)),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// --- ويدجت الأسنان ---
Widget Uppertooth(int number, String status) {
  Color color = _getToothColor(status);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10),
          ),
          boxShadow: [
            if (status != "none") BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ],
  );
}

Widget Lowertooth(int number, String status) {
  Color color = _getToothColor(status);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            if (status != "none") BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
          ],
        ),
      ),
      const SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ],
  );
}

Color _getToothColor(String status) {
  switch (status) {
    case "cavity": return const Color(0xFFFF4D6D);
    case "filling": return const Color(0xFF00E5FF);
    case "crown": return const Color(0xFFFFC300);
    case "healthy": return const Color(0xFF06D6A0);
    default: return const Color(0xFF1B263B);
  }
}

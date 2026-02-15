import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Dashboard.dart';
import 'package:smart_dental_care_system/Globale.Data.dart';
import 'package:smart_dental_care_system/pages/pateint/BookingPage.dart';
import 'package:smart_dental_care_system/pages/pateint/Habit_Tracker.dart';
import 'package:smart_dental_care_system/pages/pateint/Risk_Score.dart';
import 'package:smart_dental_care_system/pages/pateint/pateint_profile.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';

class PatientHome extends StatefulWidget {
  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  String? appointmentId;
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  Map<String, dynamic>? userData;
  bool isLoading = true;
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    DocumentSnapshot apptDoc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(uid)
        .get();

    setState(() {
      userData = doc.data() as Map<String, dynamic>;

      if (apptDoc.exists) {
        hasBooking = true;
        appointmentId = uid;
        var data = apptDoc.data() as Map<String, dynamic>;
        DateTime date = (data['date'] as Timestamp).toDate();
        String slot = data['slot'];
        appointmentInfo = "${DateFormat('EEEE, dd MMM').format(date)} at $slot";
      }

      isLoading = false;
    });
  }

  final List<Map<String, dynamic>> quickAccessItems = [
    {"icon": FontAwesomeIcons.book, "title": "Book"},
    {"icon": FontAwesomeIcons.clipboardList, "title": "Records"},
    {"icon": FontAwesomeIcons.chartLine, "title": "Risk Score"},
    {"icon": FontAwesomeIcons.chartBar, "title": "Habit Tracker "},
  ];
  String appointmentInfo = "No upcoming appointments";
  bool hasBooking = false;

  void _handleBooking() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bookingpage()),
    );

    if (result != null && result is Map) {
      setState(() {
        DateTime selectedDate = result['selectedDate'];
        String selectedSlot = result['selectedSlot'];
        appointmentId = result['appointmentId'];
        String formattedDate = DateFormat('EEEE, dd MMM').format(selectedDate);

        appointmentInfo = "$formattedDate at $selectedSlot";
        hasBooking = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 0,

        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            "Patient Home",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        centerTitle: false,
        actions: [
         
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: IconButton(
              iconSize: 28,
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PateintProfile()),
                );
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergencies')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const SizedBox();
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                String status = data['status'];

                if (status == 'waiting') return const SizedBox();

                return Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: status == 'accepted'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: status == 'accepted' ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        status == 'accepted'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: status == 'accepted' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          status == 'accepted'
                              ? "Your emergency request was accepted. Help is on the way!"
                              : "Your request was declined. Please try calling the hospital.",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white54,
                          size: 18,
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('emergencies')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                "Welcome back, ${userData?["name"]} ! ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 10),
              child: Text(
                "Your smile is our priority today.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Upcoming Appointments",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 15),

                      if (!hasBooking) ...[
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white24,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "You haven't booked an appointment yet",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _handleBooking(),
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(color: primaryBlue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              appointmentInfo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              FontAwesomeIcons.clock,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage(
                                "lib/assets/doctor.jpeg",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Dr. Emily White",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Clinic Room 3",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleBooking(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Reschedule",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF112B3C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                          color: Colors.white10,
                                        ),
                                      ),
                                      title: const Text(
                                        "Cancel Appointment",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: const Text(
                                        "Are you sure you want to cancel this booking?",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text(
                                            "No, Keep it",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFF4B5C,
                                              ).withOpacity(0.1),
                                              foregroundColor: const Color(
                                                0xFFFF4B5C,
                                              ),
                                              elevation: 0,
                                              side: const BorderSide(
                                                color: Color(0xFFFF4B5C),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              "Yes, Cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('appointments')
                                          .doc(appointmentId)
                                          .delete();
                                      setState(() {
                                        hasBooking = false;
                                        appointmentInfo =
                                            "No upcoming appointments";
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Appointment cancelled successfully",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print("Error: $e");
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D2FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.fullscreen_rounded, size: 24),
                      SizedBox(width: 10),
                      Text(
                        "Scan My Teeth",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF112B3C),
                    side: const BorderSide(color: Color(0xFF00D2FF), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: Color(0xFF00D2FF),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Smile Future Simulator",
                        style: TextStyle(
                          color: Color(0xFF00D2FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4B5C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    TextEditingController reasonController =
                        TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF112B3C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Emergency Reason",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Please describe the situation briefly:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: reasonController,
                              style: TextStyle(color: Colors.white),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    "e.g., Severe chest pain, High fever...",
                                hintStyle: TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: Colors.black26,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 5,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () async {
                                String uid =
                                    FirebaseAuth.instance.currentUser!.uid;
                                String patientName =
                                    userData?["name"] ?? "Unknown Patient";
                                String reason =
                                    reasonController.text.trim().isEmpty
                                    ? "Severe Pain"
                                    : reasonController.text;

                                await FirebaseFirestore.instance
                                    .collection('emergencies')
                                    .doc(uid)
                                    .set({
                                      'patientId': uid,
                                      'name': patientName,
                                      'reasons': reason,
                                      'contact':
                                          userData?['phone'] ?? 'No contact',
                                      'time': DateFormat(
                                        'hh:mm a',
                                      ).format(DateTime.now()),
                                      'timestamp': FieldValue.serverTimestamp(),
                                      'status': 'waiting',
                                    });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                      "Emergency alert sent successfully!",
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "SEND ALERT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        "Emergency",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Quick Access",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = quickAccessItems[index];
                  return _quickAccessCard(
                    icon: item["icon"],
                    title: item["title"],
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112B3C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          switch (index) {
            case 0:
              _handleBooking();
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PatientRecord()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RiskScore()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HabitTracker()),
              );
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF2EC4FF), size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

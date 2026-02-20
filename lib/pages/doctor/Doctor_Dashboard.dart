import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/DoctorModels/PatientAppointment.dart';
import 'package:smart_dental_care_system/pages/doctor/DoctorChatList.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Analytics.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Available_Slots.dart';
import 'package:smart_dental_care_system/pages/doctor/Emergency_Alerts.dart';
import 'package:smart_dental_care_system/Globale.Data.dart';
import 'package:smart_dental_care_system/pages/doctor/Patient_Clinical_View.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class DoctorDashboard extends StatefulWidget {
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  List<PatientAppointment> allTodayAppointments = [];
  List<PatientAppointment> filteredAppointments = [];
  Map<String, dynamic>? userData;
  bool isLoading = true;

  late Stream<QuerySnapshot> _emergencyStream;

  @override
  void initState() {
    super.initState();
    fetchData();
    _emergencyStream = FirebaseFirestore.instance
        .collection('emergencies')
        .where('status', isEqualTo: 'waiting')

        .snapshots();

  }

  fetchData() async {
    setState(() => isLoading = true);
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      userData = userDoc.data();
    }

    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    var snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    setState(() {
      allTodayAppointments = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return PatientAppointment(
          uid: data['patientId'] ?? '',
          name: data['patientName'] ?? 'Unknown',
          status: data['status'] ?? "waiting",
          treatment: data['treatment'] ?? '',
          time: data['slot'] ?? '',
          riskScore: (data['riskScore'] ?? 0).toInt(),
        );
      }).toList();

      filteredAppointments = allTodayAppointments;

      gridItems[0]["value"] = allTodayAppointments.length.toString();

      gridItems[1]["value"] = allTodayAppointments
          .where((a) => a.status == "Completed")
          .length
          .toString();

      gridItems[2]["value"] = allTodayAppointments
          .where((a) => a.status == "waiting")
          .length
          .toString();

      if (allTodayAppointments.isNotEmpty) {
        double adherence =
            (int.parse(gridItems[1]["value"]) / allTodayAppointments.length) *
            100;
        gridItems[3]["value"] = "${adherence.toStringAsFixed(0)}%";
      } else {
        gridItems[3]["value"] = "0%";
      }
      isLoading = false;
    });
  }

  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> gridItems = [
    {
      "title": "Today",
      "value": "8",
      "icon": Icons.calendar_today,
      "color": Colors.lightGreenAccent,
    },
    {
      "title": "Completed",
      "value": "3",
      "icon": Icons.check_circle_outline,
      "color": Colors.cyanAccent,
    },
    {
      "title": "waiting",
      "value": "5",
      "icon": FontAwesomeIcons.clock,
      "color": Colors.orangeAccent,
    },
    {
      "title": "Adherence",
      "value": "92%",
      "icon": Icons.trending_up,
      "color": Colors.pinkAccent,
    },
  ];

  void filterSearch(String query) {
    setState(() {
      filteredAppointments = allTodayAppointments
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.white54,
        onTap: (value) {
          switch (value) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Analytics()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorAvailableSlots()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorChatList()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: "Slots",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchController.clear();
                    filteredAppointments = allTodayAppointments;
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 8, top: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: primaryBlue,
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.stethoscope,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                  border: InputBorder.none,
                ),
                onChanged: filterSearch,
              )
            : null,
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    searchController.clear();
                    filterSearch("");
                  },
                )
              : IconButton(
                  onPressed: () => setState(() => isSearching = true),
                  icon: Icon(
                    FontAwesomeIcons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
          if (!isSearching)
            IconButton(
              onPressed: () {},
              icon: Icon(FontAwesomeIcons.bell, size: 22, color: Colors.white),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSearching) ...[
              Divider(thickness: 1, color: Colors.white10),
              SizedBox(height: 10),
              Text(
                "Welcome, Dr. ${userData?['name'] ?? ''} !",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Your daily overview at a glance.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          gridItems[index]["icon"],
                          color: gridItems[index]["color"],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gridItems[index]["title"],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              gridItems[index]["value"],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _emergencyStream,
                builder: (context, snapshot) {
                  // 1. التحقق من وجود خطأ (مثل عدم وجود Index في Firestore)
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white)));
                  }

                  // 2. التحقق من حالة التحميل
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink(); // أو مؤشر تحميل صغير
                  }

                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                  if (count == 0) return SizedBox.shrink();

                  var lastEmergency = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF4B5C).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFFF4B5C),
                          size: 28,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$count Emergency Cases",
                                style: TextStyle(
                                  color: Color(0xFFFF4B5C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lastEmergency != null
                                    ? "${lastEmergency['name']} - ${lastEmergency['reasons']}"
                                    : "New emergency alert",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4B5C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmergencyAlerts(),
                            ),
                          ),
                          child: Text(
                            "View",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 10),
              child: Text(
                isSearching
                    ? "Search Results (${filteredAppointments.length})"
                    : "Today's Appointments",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryBlue))
                  : filteredAppointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.calendarCheck,
                            size: 60,
                            color: Colors.white10,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No patients found for today",
                            style: TextStyle(color: Colors.white38),
                          ),
                          Text(
                            isSearching
                                ? "Try searching for another name"
                                : "Your schedule is clear!",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final patient = filteredAppointments[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PatientClinicalView(patientId: patient.uid),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: patient.status == "In Progress"
                                            ? Colors.cyan.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        patient.status,
                                        style: TextStyle(
                                          color: patient.status == "In Progress"
                                              ? Colors.cyanAccent
                                              : Colors.orangeAccent,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  patient.treatment,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white38,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          patient.time,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(patient.uid)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text(
                                            "Loading...",
                                            style: TextStyle(color: Colors.white38, fontSize: 13),
                                          );
                                        }

                                        var userData = snapshot.data!.data() as Map<String, dynamic>?;

                                        // ملاحظة: الصورة توضح أن المسار هو oralScore ثم score
                                        int liveRiskScore = 0;
                                        if (userData != null && userData['oralScore'] != null) {
                                          liveRiskScore = (userData['oralScore']['score'] ?? 0).toInt();
                                        }

                                        return Text(
                                          "Risk Score: $liveRiskScore",
                                          style: TextStyle(
                                            color: liveRiskScore < 80
                                                ? Colors.redAccent
                                                : Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

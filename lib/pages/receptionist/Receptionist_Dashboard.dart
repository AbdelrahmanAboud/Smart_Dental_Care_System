import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_dental_care_system/data/DoctorModels/PatientAppointment.dart';
import 'package:smart_dental_care_system/data/PateintModels/AvailableDay.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Appointment_Model.dart';
import 'package:smart_dental_care_system/pages/receptionist/QRScannerPage.dart';
import 'package:smart_dental_care_system/pages/receptionist/ReceptionChatList.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Billing%20.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Analytics.dart';
import 'package:smart_dental_care_system/pages/receptionist/Recptionist_Traffic.dart';

import 'package:smart_dental_care_system/pages/receptionist/Schedulepage.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class ReceptionistDashboard extends StatefulWidget {
  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
  List<AppointmentModel> allTodayAppointments = [];
  List<AppointmentModel> filteredList = [];
  bool isLoading = true;
  late Timer _timer;
  String _currentTime = "";
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  List<AvailableDay> availabledays = [];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    fetchAvailableSlots();
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getAppointmentsStream() {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots();
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      int hour = now.hour > 12
          ? now.hour - 12
          : (now.hour == 0 ? 12 : now.hour);
      String amPm = now.hour >= 12 ? "PM" : "AM";
      _currentTime =
          "$hour:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm";
    });
  }

  Future<void> fetchAvailableSlots() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('available_slots')
          .get();

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime lastAllowedDay = today.add(const Duration(days: 7));

      Set<String> uniqueDates = {};

      for (var doc in snapshot.docs) {
        String docId = doc.id;

        if (docId.contains('_')) {
          String datePart = docId.split('_').last;
          uniqueDates.add(datePart);
        } else {
          uniqueDates.add(docId);
        }
      }

      List<AvailableDay> loadedDays = uniqueDates
          .map((dateStr) {
            return AvailableDay(date: dateStr, slots: []);
          })
          .where((availableDay) {
            try {
              DateTime checkDate = DateTime.parse(availableDay.date);
              return (checkDate.isAtSameMomentAs(today) ||
                      checkDate.isAfter(today)) &&
                  checkDate.isBefore(
                    lastAllowedDay.add(const Duration(days: 1)),
                  );
            } catch (e) {
              return false;
            }
          })
          .toList();

      loadedDays.sort(
        (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
      );

      setState(() {
        availabledays = loadedDays;
        isLoading = false;
      });

      print("Successfully loaded ${availabledays.length} unique dates.");
    } catch (e) {
      print("Error fetching slots: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterSearch(String query) {
    setState(() {
      filteredList = allTodayAppointments
          .where(
            (item) =>
                item.patientName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> handleQRScan(String scannedId, BuildContext context) async {
    try {
      Map<String, dynamic> data = jsonDecode(scannedId);
      String pId = (data['uid'] ?? data['UID'] ?? "").toString().trim();

      if (pId.isEmpty) return;

      var querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: pId)
          .get();

      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        var appointmentDoc = querySnapshot.docs.first;
        var appointmentData = appointmentDoc.data();
        String currentStatus = appointmentData['status'] ?? "";
        String pName = appointmentData['patientName'] ?? "Patient";
        String docId = appointmentDoc.id;

        if (currentStatus == 'Pending') {
          await FirebaseFirestore.instance
              .collection('appointments')
              .doc(docId)
              .update({'status': 'Confirmed'});

          if (context.mounted) _showSuccessDialog(context, pName);
        } else if (currentStatus == 'Confirmed') {
          if (context.mounted) _showAlreadyArrivedDialog(context, pName);
        } else {
          if (context.mounted) _showNoBookingDialog(context);
        }
      } else {
        if (context.mounted) _showNoBookingDialog(context);
      }
    } catch (e) {
      print("Runtime Error: $e");
    }
  }

  void _showSuccessDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1C2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, $name",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Arrival recorded successfully!",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Done",
                style: TextStyle(color: Color(0xFF0B1C2D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlreadyArrivedDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1C2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.blueAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              "Hello, $name",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You are already checked in. Please wait for your turn.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1C2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.orangeAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            const Text(
              "No Appointment Found",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "No pending booking found for this patient.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Schedulepage()),
                      );
                    },
                    child: const Text(
                      "Book Now",
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index) {
    final patient = filteredList[index];
    TextEditingController nameController = TextEditingController(
      text: patient.patientName,
    );

    String? selectedDoctorId;
    String? selectedDoctorName;
    String tempSelectedTime = patient.appointmentTime;
    AvailableDay? selectedDay;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C2D),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Edit Appointment",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Assigned Doctor",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'Doctor')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return const LinearProgressIndicator();
                          var doctors = snapshot.data!.docs;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF112B3C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDoctorId,
                                hint: const Text(
                                  "Select Doctor",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                                dropdownColor: const Color(0xFF0B1C2D),
                                isExpanded: true,
                                items: doctors.map((doc) {
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text(
                                      doc['name'] ?? 'Doctor',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedDoctorId = val;
                                    selectedDoctorName = doctors.firstWhere(
                                      (d) => d.id == val,
                                    )['name'];
                                    selectedDay = null;
                                    tempSelectedTime = "";
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Select Date",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availabledays.length,
                          itemBuilder: (context, dIndex) {
                            final day = availabledays[dIndex];
                            bool isSelected = (selectedDay == day);
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedDay = day),
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryBlue
                                      : const Color(0xFF112B3C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      day.date,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (selectedDay != null && selectedDoctorId != null) ...[
                        const Text(
                          "Available Slots",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<String>>(
                          future: _getDoctorSlots(
                            selectedDoctorId!,
                            selectedDay!.date,
                          ),
                          builder: (context, slotSnapshot) {
                            if (slotSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            var slots = slotSnapshot.data ?? [];
                            if (slots.isEmpty) {
                              return const Text(
                                "No slots for this doctor on this day",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11,
                                ),
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: slots.map((slot) {
                                bool isSlotSelected = tempSelectedTime == slot;
                                return GestureDetector(
                                  onTap: () => setDialogState(
                                    () => tempSelectedTime = slot,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSlotSelected
                                          ? primaryBlue.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSlotSelected
                                            ? primaryBlue
                                            : Colors.white10,
                                      ),
                                    ),
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        color: isSlotSelected
                                            ? primaryBlue
                                            : Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ] else ...[
                        const Center(
                          child: Text(
                            "Please select a doctor and date first",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Discard",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              onPressed: () async {
                                if (tempSelectedTime.isEmpty ||
                                    selectedDay == null ||
                                    selectedDoctorId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please complete selections",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  DateTime parsedDate = DateTime.parse(
                                    selectedDay!.date,
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(patient.uid)
                                      .update({
                                        'slot': tempSelectedTime,
                                        'date': Timestamp.fromDate(parsedDate),
                                        'doctorId': selectedDoctorId,
                                        'doctorName': selectedDoctorName,
                                      });

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Appointment Updated Successfully!",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  print("Update Error: $e");
                                }
                              },
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Save Changes",
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<String>> _getDoctorSlots(
    String doctorId,
    String dateString,
  ) async {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      String docId = "${doctorId}_$formattedDate";

      print("Fetching Document ID: $docId");

      var doc = await FirebaseFirestore.instance
          .collection('available_slots')
          .doc(docId)
          .get();

      if (doc.exists) {
        List<String> slots = List<String>.from(doc.data()?['slots'] ?? []);
        print("Slots found: $slots");
        return slots;
      } else {
        print("Document does not exist in Firebase!");
      }
    } catch (e) {
      print("Error in _getDoctorSlots: $e");
    }
    return [];
  }

  void _showCancelDialog(int index) {
    final patient = filteredList[index];
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1C2D),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Cancel Appointment?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "Are you sure you want to cancel "),
                      TextSpan(
                        text: "${patient.patientName}'s ",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "appointment?"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112B3C),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogInfoRow("Time:", patient.appointmentTime),
                      const SizedBox(height: 8),
                      _buildDialogInfoRow("Treatment:", patient.treatmentType),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Keep",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(patient.uid)
                                .delete();

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Appointment cancelled successfully",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          } catch (e) {
                            print("Error cancelling appointment: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to cancel: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Yes, Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gridItems = [
      {
        "title": "Total",
        "value": allTodayAppointments.length.toString(),
        "color": Colors.lightGreenAccent,
      },
      {
        "title": "Confirmed",
        "value": allTodayAppointments
            .where((a) => a.status.toLowerCase() == "confirmed")
            .length
            .toString(),
        "color": Colors.cyanAccent,
      },
      {
        "title": "Pending",
        "value": allTodayAppointments
            .where((a) => a.status.toLowerCase() == "pending")
            .length
            .toString(),
        "color": Colors.orangeAccent,
      },
      {
        "title": "Current Time",
        "value": _currentTime,
        "color": Colors.greenAccent,
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClinicTraffic()),
              );
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsReceptionist(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Billing()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceptionChatList()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.usersLine),
            label: "Traffic",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Billing",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    filteredList = allTodayAppointments;
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: _filterSearch,
              )
            : const Text(
                "Daily Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearch("");
                  },
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                      tooltip: 'Scan Patient QR',
                      onPressed: () async {
                        final String? scannedId = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRScannerPage(),
                          ),
                        );

                        if (scannedId != null) {
                          print("Scanned ID successfully: $scannedId");

                          handleQRScan(scannedId, context);
                        } else {
                          print("No ID was scanned or user went back.");
                        }
                      },
                    ),
                    const SizedBox(width: 8),

                    IconButton(
                      onPressed: () => setState(() => _isSearching = true),
                      icon: Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Schedulepage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          final docs = snapshot.data?.docs ?? [];
          allTodayAppointments = docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return AppointmentModel(
              uid: doc.id,
              patientName: data['patientName'] ?? 'Unknown',
              appointmentTime: data['slot'] ?? '',
              treatmentType: data['treatment'] ?? '',
              status: data['status'] ?? "Pending",
              doctorName: data['doctorName'] ?? 'No Doctor',
            );
          }).toList();

          if (!_isSearching) {
            filteredList = allTodayAppointments;
          }

          int confirmed = allTodayAppointments
              .where((a) => a.status.toLowerCase() == "confirmed")
              .length;
          int pending = allTodayAppointments
              .where((a) => a.status.toLowerCase() == "pending")
              .length;

          gridItems[0]["value"] = allTodayAppointments.length.toString();
          gridItems[1]["value"] = confirmed.toString();
          gridItems[2]["value"] = pending.toString();
          gridItems[3]["value"] = _currentTime;

          return SingleChildScrollView(
            child: Column(
              children: [
                if (!_isSearching) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gridItems.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.4,
                        ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gridItems[index]["value"],
                              style: TextStyle(
                                color: gridItems[index]["color"],
                                fontSize: index == 3 ? 16 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gridItems[index]["title"],
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Today's Patients",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                filteredList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                FontAwesomeIcons.calendarCheck,
                                size: 60,
                                color: Colors.white10,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No patients found for today",
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isSearching
                                    ? "Try searching for another name"
                                    : "Your schedule is clear!",
                                style: const TextStyle(
                                  color: Colors.white24,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: _isSearching ? 20 : 0,
                        ),
                        itemBuilder: (context, index) {
                          final patient = filteredList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 17,
                                          backgroundColor: primaryBlue
                                              .withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            size: 20,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient.patientName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),

                                            const SizedBox(height: 10),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: primaryBlue.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.userDoctor,
                                                    size: 11,
                                                    color: primaryBlue,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "Dr. ${patient.doctorName}",
                                                    style: TextStyle(
                                                      color: primaryBlue,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (patient.status.toLowerCase() ==
                                                        "confirmed"
                                                    ? Colors.greenAccent
                                                    : Colors.orangeAccent)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        patient.status.toUpperCase(),
                                        style: TextStyle(
                                          color:
                                              patient.status.toLowerCase() ==
                                                  "confirmed"
                                              ? Colors.greenAccent
                                              : Colors.orangeAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(
                                  height: 25,
                                  color: Colors.white10,
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.white38,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          patient.appointmentTime,
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        _buildActionButton(
                                          "Edit",
                                          Colors.white70,
                                          () => _showEditDialog(index),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          "Cancel",
                                          const Color(0xFFFF4B5C),
                                          () => _showCancelDialog(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

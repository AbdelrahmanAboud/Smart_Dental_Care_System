import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/DoctorModels/PatientAppointment.dart';
import 'package:smart_dental_care_system/data/PateintModels/AvailableDay.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Appointment_Model.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Billing%20.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Analytics.dart';
import 'package:smart_dental_care_system/pages/receptionist/Recptionist_Traffic.dart';
import 'package:smart_dental_care_system/pages/receptionist/SchedulePage.dart';

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
    fetchData();
    fetchAvailableSlots();
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
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

  fetchData() async {
    setState(() => isLoading = true);

    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      setState(() {
        allTodayAppointments = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return AppointmentModel(
            uid: doc.id,
            patientName: data['patientName'] ?? 'Unknown',
            appointmentTime: data['slot'] ?? '',
            treatmentType: data['treatment'] ?? '',
            status: data['status'] ?? "pending",
          );
        }).toList();

        filteredList = allTodayAppointments;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAvailableSlots() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('available_slots')
          .get();

      setState(() {
        availabledays = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();

          String displayDate = doc.id;

          return AvailableDay(
            date: displayDate,
            slots: List<String>.from(data['slots'] ?? []),
          );
        }).toList();

        availabledays.sort((a, b) => a.date.compareTo(b.date));
      });
    } catch (e) {
      print("Error fetching slots: $e");
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

  void _showEditDialog(int index) {
    final patient = filteredList[index];
    TextEditingController nameController = TextEditingController(
      text: patient.patientName,
    );
    String tempSelectedTime = patient.appointmentTime;
    String tempSelectedTreatment = patient.treatmentType;
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
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryBlue.withOpacity(0.1),
                        child: Icon(
                          Icons.edit_outlined,
                          color: primaryBlue,
                          size: 30,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Edit Appointment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112B3C),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildDialogInfoRow(
                              "Current Time:",
                              tempSelectedTime,
                            ),
                            const SizedBox(height: 8),
                            _buildDialogInfoRow(
                              "Treatment:",
                              tempSelectedTreatment,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Select Time Slot",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(height: 10),
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
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white24
                                        : Colors.transparent,
                                  ),
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
                      if (selectedDay != null) ...[
                        Text(
                          "Available Slots",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedDay!.slots.map((slot) {
                            bool isSlotSelected = tempSelectedTime == slot;
                            return GestureDetector(
                              onTap: () =>
                                  setDialogState(() => tempSelectedTime = slot),
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
                        ),
                      ] else
                        Center(
                          child: Text(
                            "Please select a date first",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Discard",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (tempSelectedTime.isEmpty ||
                                    selectedDay == null)
                                  return;

                                try {
                                  DateTime parsedDate = DateTime.parse(
                                    selectedDay!.date,
                                  );
                                  Timestamp dateTimestamp = Timestamp.fromDate(
                                    parsedDate,
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .doc(patient.uid)
                                      .update({
                                        'patientName': nameController.text,
                                        'slot': tempSelectedTime,
                                        'date': dateTimestamp,
                                      });

                                  await fetchData();
                                  Navigator.pop(context);
                                } catch (e) {
                                  print("Error: $e");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                "Save Changes",
                                style: TextStyle(
                                  color: Colors.black,
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
              ),
            );
          },
        );
      },
    );
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

                            setState(() {
                              allTodayAppointments.removeWhere(
                                (item) => item.uid == patient.uid,
                              );
                              _filterSearch(_searchController.text);
                            });

                            Navigator.pop(context);

                            // اختياري: إظهار رسالة نجاح
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Appointment cancelled successfully",
                                ),
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
            .where((a) => a.status == "confirmed")
            .length
            .toString(),
        "color": Colors.cyanAccent,
      },
      {
        "title": "Pending",
        "value": allTodayAppointments
            .where((a) => a.status == "pending")
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ClinicTraffic()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsReceptionist(),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Billing()),
              );
              break;
            case 4:
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
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _filterSearch("");
                  },
                )
              : IconButton(
                  onPressed: () => setState(() => _isSearching = true),
                  icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
                ),
          // if (!_isSearching)
          // IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Schedulepage())), icon: Icon(Icons.add, size: 26)),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
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
                                Icon(
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
                                  style: TextStyle(
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
                                    children: [
                                      Row(
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
                                              Text(
                                                patient.treatmentType,
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        patient.status.toUpperCase(),
                                        style: TextStyle(
                                          color: patient.status == "confirmed"
                                              ? Colors.greenAccent
                                              : Colors.orangeAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
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
                                      Text(
                                        patient.appointmentTime,
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                            Color(0xFFFF4B5C),
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

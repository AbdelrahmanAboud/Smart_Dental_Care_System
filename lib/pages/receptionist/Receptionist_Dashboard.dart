import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/PateintModels/AvailableDay.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Appointment_Model.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Analytics.dart';
import 'package:smart_dental_care_system/pages/receptionist/Recptionist_Traffic.dart';
import 'package:smart_dental_care_system/pages/receptionist/SchedulePage.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class ReceptionistDashboard extends StatefulWidget {
  @override
  State<ReceptionistDashboard> createState() => _SchedulepageState();
}

class _SchedulepageState extends State<ReceptionistDashboard> {
  late Timer _timer;
  String _currentTime = "";
  TextEditingController _searchController = TextEditingController();
  List<AppointmentModel> filteredList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
    filteredList = appointmentList;
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
      int hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      String amPm = now.hour >= 12 ? "PM" : "AM";
      _currentTime = "$hour:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $amPm";
    });
  }

  void _filterSearch(String query) {
    setState(() {
      filteredList = appointmentList
          .where((item) => item.patientName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showEditDialog(int index) {
    final patient = filteredList[index];
    TextEditingController nameController = TextEditingController(text: patient.patientName);
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
                  border: Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primaryBlue.withOpacity(0.1),
                        child: Icon(Icons.edit_outlined, color: primaryBlue, size: 30),
                      ),
                      SizedBox(height: 20),
                      Text("Edit Appointment", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: const Color(0xFF112B3C), borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            _buildDialogInfoRow("Current Time:", tempSelectedTime),
                            const SizedBox(height: 8),
                            _buildDialogInfoRow("Treatment:", tempSelectedTreatment),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text("Select Time Slot", style: TextStyle(color: Colors.white, fontSize: 12)),
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
                              onTap: () => setDialogState(() => selectedDay = day),
                              child: Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryBlue : const Color(0xFF112B3C),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? Colors.white24 : Colors.transparent),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(day.date, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (selectedDay != null) ...[
                        Text("Available Slots", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedDay!.slots.map((slot) {
                            bool isSlotSelected = tempSelectedTime == slot;
                            return GestureDetector(
                              onTap: () => setDialogState(() => tempSelectedTime = slot),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSlotSelected ? primaryBlue.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSlotSelected ? primaryBlue : Colors.white10),
                                ),
                                child: Text(slot, style: TextStyle(color: isSlotSelected ? primaryBlue : Colors.white60, fontSize: 11)),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else
                        Center(child: Text("Please select a date first", style: TextStyle(color: Colors.white24, fontSize: 11))),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Discard", style: TextStyle(color: Colors.white70)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  int originalIndex = appointmentList.indexOf(filteredList[index]);
                                  appointmentList[originalIndex] = AppointmentModel(
                                    patientName: nameController.text,
                                    appointmentTime: tempSelectedTime,
                                    treatmentType: tempSelectedTreatment,
                                    status: patient.status,
                                  );
                                  _filterSearch(_searchController.text);
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text("Save Changes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 30),
                ),
                const SizedBox(height: 20),
                const Text("Cancel Appointment?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    children: [
                      const TextSpan(text: "Are you sure you want to cancel "),
                      TextSpan(text: "${patient.patientName}'s ", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      const TextSpan(text: "appointment?"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Color(0xFF112B3C), borderRadius: BorderRadius.circular(15)),
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
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.white10, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Keep", style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            appointmentList.remove(filteredList[index]);
                            _filterSearch(_searchController.text);
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gridItems = [
      {"title": "Total", "value": appointmentList.length.toString(), "color": Colors.lightGreenAccent},
      {"title": "Confirmed", "value": "3", "color": Colors.cyanAccent},
      {"title": "Pending", "value": "5", "color": Colors.orangeAccent},
      {"title": "Current Time", "value": _currentTime, "color": Colors.greenAccent},
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
          MaterialPageRoute(builder: (context) => AnalyticsReceptionist()),
        );
        break;

      case 3:
      
        break;
    }
  },

  items:  [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon( FontAwesomeIcons.usersLine),
      label: "Traffic",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: "Analytics",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: "Chat",
    ),
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
                    filteredList = appointmentList;
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search patient name...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                  border: InputBorder.none,
                ),
                onChanged: _filterSearch,
              )
            : const Text(
                "Daily Overview",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              : IconButton(
                  onPressed: () => setState(() => _isSearching = true),
                  icon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
          if (!_isSearching)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Schedulepage()));
              },
              icon: Icon(Icons.add, size: 26, color: Colors.white),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!_isSearching) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridItems.length,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        Text(gridItems[index]["value"].toString(), style: TextStyle(color: gridItems[index]["color"], fontSize: index == 3 ? 18 : 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(gridItems[index]["title"], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Today's Patients", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: _isSearching ? 20 : 0),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryBlue.withOpacity(0.5)),
                                ),
                                child: Icon(Icons.person, size: 20, color: primaryBlue),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patient.patientName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text(patient.treatmentType, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Text(patient.status.toUpperCase(), style: TextStyle(color: patient.status == "confirmed" ? Colors.greenAccent : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 25, color: Colors.white10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(patient.appointmentTime, style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _showEditDialog(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  foregroundColor: Colors.white70,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white70.withOpacity(0.3))),
                                ),
                                child: Text("Edit", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _showCancelDialog(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  foregroundColor: Color(0xFFFF4B5C),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Color(0xFFFF4B5C).withOpacity(0.3))),
                                ),
                                child: Text("Cancel", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
}
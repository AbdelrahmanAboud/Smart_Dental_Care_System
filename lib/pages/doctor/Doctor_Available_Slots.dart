import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class DoctorAvailableSlots extends StatefulWidget {
  @override
  State<DoctorAvailableSlots> createState() => _DoctorAvailableSlotsState();
}

class _DoctorAvailableSlotsState extends State<DoctorAvailableSlots> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<String> availableSlots = [];
  final TextEditingController _slotController = TextEditingController();

  @override
  void dispose() {
    _slotController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryBlue, 
              onPrimary: Colors.black,
              surface: cardColor, 
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: bgColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _slotController.text = picked.format(context);
      });
    }
  }

  Future<void> _loadSlotsForDate(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final doc = await FirebaseFirestore.instance
        .collection('available_slots')
        .doc(dateKey)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        availableSlots = List<String>.from(data['slots'] ?? []);
      });
    } else {
      setState(() {
        availableSlots = [];
      });
    }
  }

  Future<void> _addSlot() async {
    if (_slotController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot")),
      );
      return;
    }
    if (selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay!);
    final slot = _slotController.text.trim();

    if (availableSlots.contains(slot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This slot already exists")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('available_slots')
          .doc(dateKey)
          .set({
        'date': Timestamp.fromDate(selectedDay!),
        'slots': FieldValue.arrayUnion([slot]),
      }, SetOptions(merge: true));

      _slotController.clear();
      _loadSlotsForDate(selectedDay!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Slot added successfully"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteSlot(String slot) async {
    if (selectedDay == null) return;
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDay!);

    try {
      await FirebaseFirestore.instance
          .collection('available_slots')
          .doc(dateKey)
          .update({
        'slots': FieldValue.arrayRemove([slot]),
      });

      _loadSlotsForDate(selectedDay!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Slot deleted"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Available Slots",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Date",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                  _loadSlotsForDate(selected);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  outsideTextStyle: const TextStyle(color: Colors.white38),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      const TextStyle(color: Colors.white, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlue),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (selectedDay != null) ...[
              Text(
                "Available Slots for ${DateFormat('EEEE, MMM dd').format(selectedDay!)}",
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _slotController,
                      readOnly: true,
                      onTap: () => _selectTime(context), 
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Click to select time",
                        prefixIcon: Icon(Icons.access_time, color: primaryBlue),
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addSlot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Add",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (availableSlots.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      "No slots available for this day",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableSlots.map((slot) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slot,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _deleteSlot(slot),
                            child: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    "Please select a date to manage slots",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_dental_care_system/data/PateintModels/AvailableDay.dart';
import 'package:table_calendar/table_calendar.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);
const Color primaryDark = Color(0xFF141F38);
const Color accentCyan = Color(0xFF00CCFF);

class Bookingpage extends StatefulWidget {
  @override
  State<Bookingpage> createState() => _BookingpageState();
}

class _BookingpageState extends State<Bookingpage> {
  List<String> treatments = ['Consultation', 'Cleaning', 'Filling', 'Extraction', 'Root Canal'];
String selectedTreatment = 'Consultation';
  
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  List<String> todaySlots = [];
  String? selectedSlot;

  @override
  Widget build(BuildContext context) {
    if (selectedDay != null) {
      final key = DateFormat('yyyy-MM-dd').format(selectedDay!);
      final day = availabledays.firstWhere(
        (d) => d.date == key,
        orElse: () => AvailableDay(date: key, slots: []),
      );
      todaySlots = day.slots;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          "Book Appointment",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
        ),
      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.chevron_left, color: primaryBlue),
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(
                            focusedDay.year,
                            focusedDay.month - 1,
                          );
                        });
                      },
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(focusedDay),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.chevron_right, color: primaryBlue),
                      onPressed: () {
                        setState(() {
                          focusedDay = DateTime(
                            focusedDay.year,
                            focusedDay.month + 1,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
          
              Container(
                height: 350,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
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
                  padding: const EdgeInsets.all(10.0),
                  child: TableCalendar(
                    // sixWeekMonthsEnforced: true,
                    firstDay: DateTime.now().subtract(Duration(days: 365)),
                    lastDay: DateTime.now().add(Duration(days: 365)),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                        selectedSlot = null;
                      });
                    },
          
                    headerVisible: false,
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white),
                      outsideTextStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white),
                      weekendStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
          
         Text(
  "Select Treatment Type:", 
  textAlign: TextAlign.start, 
  style: TextStyle(
    color: Colors.white, 
    fontSize: 16, 
    fontWeight: FontWeight.bold
  ),
),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryBlue.withOpacity(0.5)),
            ),
            child: DropdownButton<String>(
              value: selectedTreatment,
              dropdownColor: cardColor,
              isExpanded: true,
              underline: SizedBox(), 
              style: TextStyle(color: Colors.white, fontSize: 16),
              items: treatments.map((String value) {
                return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
          selectedTreatment = newValue!;
                });
              },
            ),
          ),
          SizedBox(height: 16),
              // ----- Display Available Slots -----
              if (selectedDay != null)
                
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Available Time Slots:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (todaySlots.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              "No slots available",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        )
                      else
                           
                                 Center(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: todaySlots.map((slot) {
                                      final isSelected = slot == selectedSlot;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedSlot = slot;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? primaryBlue
                                                : cardColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            slot,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                      
                        
                    ],
                  ),
                
          
              
            ],
          ),
        ),
      ),
    bottomNavigationBar: Padding (
    padding:  EdgeInsets.all(16.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
  onPressed: () async {
  if (selectedSlot != null && selectedDay != null) {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // بنجيب بيانات المريض
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // بنحل مشكلة الـ Risk Score هنا:
      // لو الحقل مش موجود، بنحط قيمة افتراضية "0" مثلاً بدل ما يدي Error
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      String patientName = data['name'] ?? "Unknown Patient";
      var riskScore = data.containsKey('riskScore') ? data['riskScore'] : 0 ;

      // الحجز باستخدام الـ UID كعنوان للمستند لمنع التكرار
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(uid) 
          .set({
        'patientId': uid,
        'patientName': patientName,
        'riskScore': riskScore, // كده مش هيضرب لو مش موجود
        'date': selectedDay,
        'slot': selectedSlot,
        'treatment': selectedTreatment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // بعد الحجز بنجاح، بنفتح الـ Dialog
      showBookingDialog(context, selectedSlot!, selectedDay!);

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }
  }
},
  style: ElevatedButton.styleFrom(
          elevation: selectedSlot != null ? 8 : 0,
          shadowColor: primaryBlue.withOpacity(0.4),
          backgroundColor: selectedSlot != null ? primaryBlue : const Color(0xFF162A3D),
          padding:  EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          "Confirm Booking",
          style: TextStyle(
            color: selectedSlot != null ? Colors.white : Colors.white38,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
    );
  }
}
void showBookingDialog(BuildContext context, String slot, DateTime date) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient:  LinearGradient(
              colors: [accentCyan, Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding:  EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:  EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: accentCyan.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentCyan.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child:  Icon(Icons.stars_rounded, size: 60, color: accentCyan),
                ),
                 SizedBox(height: 25),
                 Text(
                  "AWESOME!",
                  style: TextStyle(
                    fontSize: 26,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your spot is secured",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 106, 188, 208).withOpacity(0.8),
                  ),
                ),
                 SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        slot,
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       SizedBox(height: 5),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(date),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 35),
                GestureDetector(
              onTap: () {
  String userUid = FirebaseAuth.instance.currentUser!.uid;

  // 1. اقفل الـ Dialog
  Navigator.of(context).pop(); 

  // 2. اقفل صفحة الحجز وارجع للـ Home ومعاك الداتا
  Navigator.of(context).pop({
    'selectedDate': date,
    'selectedSlot': slot,
    'appointmentId': userUid, // الـ ID هو الـ UID
  });
},
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentCyan, Color(0xFF0099FF)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: accentCyan.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:  Center(
                      child: Text(
                        "GREAT",
                        style: TextStyle(
                          color: primaryDark,
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
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/pages/doctor/Patient_Clinical_View.dart';
import 'package:smart_dental_care_system/pages/pateint/BookingPage.dart';
import 'package:smart_dental_care_system/pages/pateint/Habit_Tracker.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Dashboard.dart';
import 'package:smart_dental_care_system/pages/pateint/login.dart';
import 'package:smart_dental_care_system/pages/pateint/login.dart';
import 'package:smart_dental_care_system/pages/pateint/pateint_profile.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Reminders.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Dashboard.dart';

 final Color bgColor = const Color(0xFF0B1C2D);
 final Color primaryBlue = const Color(0xFF2EC4FF);
 final Color cardColor = const Color(0xFF112B3C);

void main() {
runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Login(),
)
); 
}

import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Home.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Reminders.dart';


class NavigitionBar extends StatefulWidget {
  @override
  State<NavigitionBar> createState() => _NavigitionBarState();
}

class _NavigitionBarState extends State<NavigitionBar> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PatientHome(),
      PatientRecord(),
       PatientReminders(),
      // ChatPage(),
     
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: cardColor,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Records",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Reminders",
          ),
         
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}

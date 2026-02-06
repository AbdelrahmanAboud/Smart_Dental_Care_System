import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/PateintModels/ReminderModel.dart';

class PatientReminders extends StatefulWidget {
  const PatientReminders({super.key});

  @override
  State<PatientReminders> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<PatientReminders> {
  final Color bgColor = const Color(0xFF06101E);
  final Color cardColor = const Color(0xFF102136);
  final Color accentBlue = const Color(0xFF00E5FF);

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'medication': return FontAwesomeIcons.pills;
      case 'hygiene': return FontAwesomeIcons.tooth;
      case 'ice_pack': return FontAwesomeIcons.snowflake;
      case 'refill': return FontAwesomeIcons.flask;
      default: return FontAwesomeIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: remindersList.length,
        itemBuilder: (context, index) {
          final reminder = remindersList[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(reminder.iconType), color: accentBlue, size: 22),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            reminder.description,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: accentBlue, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          reminder.time,
                          style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      reminder.date,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notes, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text("NotepadTextDashed", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                    
                      },
                      icon: Icon(Icons.check_circle_outline, color: bgColor, size: 20),
                      label: Text(
                        "Done",
                        style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        elevation: 0,
                        minimumSize: const Size(110, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
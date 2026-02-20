import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'notification_helpe.dart'; // تأكد أن الاسم مطابق للملف عندك

class PatientReminders extends StatefulWidget {
  const PatientReminders({super.key});

  @override
  State<PatientReminders> createState() => _PatientRemindersState();
}

class _PatientRemindersState extends State<PatientReminders> {
  final Color bgColor = const Color(0xFF06101E);
  final Color cardColor = const Color(0xFF102136);
  final Color accentBlue = const Color(0xFF00E5FF);

  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // 1. Initialize Notification System
    NotificationHelper.init();
  }

  // Method to schedule local notifications
  void _scheduleAppNotification(String docId, Map<String, dynamic> data) {
    DateTime scheduledDate = (data['scheduledTime'] as Timestamp).toDate();

    // نبرمج الإشعار فقط لو كان وقته في المستقبل
    if (scheduledDate.isAfter(DateTime.now())) {
      NotificationHelper.scheduleNotification(
        id: docId.hashCode.abs(),
        // هنا التأكد إن العنوان بيقرأ صح سواء دواء أو غسيل سنان
        title: data['title'] ?? (data['iconType'] == 'hygiene' ? "Tooth Brushing" : "Medical Reminder"),
        body: data['description'] ?? "Time for your oral hygiene routine",
        scheduledDate: scheduledDate,
      );
    }
  }

  IconData _getIcon(String? iconType) {
    switch (iconType) {
      case 'medication': return FontAwesomeIcons.pills;
      case 'hygiene': return FontAwesomeIcons.tooth;
      case 'ice_pack': return FontAwesomeIcons.snowflake;
      case 'refill': return FontAwesomeIcons.flask;
      default: return FontAwesomeIcons.bell;
    }
  }

  // --- ADD HYGIENE MANUALLY ---
  Future<void> _addHygieneReminderManually() async {
    try {
      await FirebaseFirestore.instance.collection('reminders').add({
        'patientId': currentUserId,
        'title': "Tooth Brushing",
        'description': "Daily oral hygiene routine",
        'iconType': 'hygiene',
        'scheduledTime': Timestamp.now(), // Appears immediately
        'isDone': false,
      });
      _showSnack("Hygiene reminder added successfully!");
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  // --- MARK AS DONE LOGIC ---
  Future<void> _markAsDone(String docId, Map<String, dynamic> data) async {
    try {
      // 1. Mark current as finished
      await FirebaseFirestore.instance.collection('reminders').doc(docId).update({'isDone': true});
      NotificationHelper.cancelNotification(docId.hashCode.abs());

      DateTime currentTime = (data['scheduledTime'] as Timestamp).toDate();
      DateTime nextReminder = currentTime.add(const Duration(hours: 12));

      // 2. Hygiene Logic (Infinite Loop every 12 hours)
      // --- حالة غسيل الأسنان ---
      if (data['iconType'] == 'hygiene') {
        await FirebaseFirestore.instance.collection('reminders').add({
          'patientId': currentUserId,
          'title': data['title'] ?? "Tooth Brushing", // تأكد من وجود العنوان
          'description': data['description'] ?? "Keep your smile clean",
          'iconType': 'hygiene',
          'scheduledTime': Timestamp.fromDate(nextReminder),
          'isDone': false,
        });
        _showSnack("Hygiene reminder set for the next 12 hours.");
      }

      // 3. Medication Logic (Repeat until endDate)
      else if (data['iconType'] == 'medication' && data.containsKey('endDate')) {
        DateTime endDate = (data['endDate'] as Timestamp).toDate();

        if (nextReminder.isBefore(endDate)) {
          await FirebaseFirestore.instance.collection('reminders').add({
            'patientId': currentUserId,
            'title': data['title'],
            'description': data['description'],
            'iconType': 'medication',
            'scheduledTime': Timestamp.fromDate(nextReminder),
            'endDate': data['endDate'],
            'isDone': false,
          });
          _showSnack("Dose recorded! Next reminder in 12 hours.");
        } else {
          _showSnack("Course completed! Stay healthy.", isSuccess: true);
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : accentBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      // Floating Action Button to add Hygiene manually
      floatingActionButton: FloatingActionButton(
        onPressed: _addHygieneReminderManually,
        backgroundColor: accentBlue,
        child: const Icon(FontAwesomeIcons.tooth, color: Color(0xFF06101E)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reminders')
            .where('patientId', isEqualTo: currentUserId)
            .where('isDone', isEqualTo: false)
            .orderBy('scheduledTime') // تأكد من عمل الـ Index كما شرحنا سابقاً
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentBlue));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No upcoming reminders", style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          final remindersDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: remindersDocs.length,
            itemBuilder: (context, index) {
              var data = remindersDocs[index].data() as Map<String, dynamic>;
              String docId = remindersDocs[index].id;

              _scheduleAppNotification(docId, data);

              DateTime dateTime = (data['scheduledTime'] as Timestamp).toDate();
              String time = DateFormat('hh:mm a').format(dateTime);
              String date = DateFormat('MMM d, yyyy').format(dateTime);

              return _buildReminderItem(docId, data, time, date);
            },
          );
        },
      ),
    );
  }

  Widget _buildReminderItem(String docId, Map<String, dynamic> data, String time, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: accentBlue.withOpacity(0.1),
                    shape: BoxShape.circle
                ),
                child: Icon(_getIcon(data['iconType']), color: accentBlue, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        data['title'] ?? 'Reminder',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 6),
                    Text(
                        data['description'] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)
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
                  Text(time, style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Center(
                      child: Text("Notes", style: TextStyle(color: Colors.white70))
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _markAsDone(docId, data),
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(120, 48)
                ),
                child: const Text(
                    "Done",
                    style: TextStyle(color: Color(0xFF06101E), fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

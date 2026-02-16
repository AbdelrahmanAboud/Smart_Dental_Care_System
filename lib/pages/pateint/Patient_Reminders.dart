import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'notification_helpe.dart';

class PatientReminders extends StatefulWidget {
  const PatientReminders({super.key});

  @override
  State<PatientReminders> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<PatientReminders> {
  final Color bgColor = const Color(0xFF06101E);
  final Color cardColor = const Color(0xFF102136);
  final Color accentBlue = const Color(0xFF00E5FF);

  final CollectionReference remindersRef =
  FirebaseFirestore.instance.collection('reminders');

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    await NotificationHelper.init();
    _listenAndScheduleReminders();
  }

  void _listenAndScheduleReminders() {
    remindersRef
        .where('patientId', isEqualTo: 'user_123')
        .where('isDone', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['scheduledTime'] != null) {
          DateTime dateTime = (data['scheduledTime'] as Timestamp).toDate();

          // التأكد من أن الموعد في المستقبل
          if (dateTime.isAfter(DateTime.now())) {
            NotificationHelper.scheduleNotification(
              id: doc.id.hashCode.abs(),
              title: data['title'] ?? 'Reminder',
              body: data['description'] ?? 'Stay on track!',
              // التعديل هنا: استخدم الوقت القادم من الداتابيز
              scheduledDate: dateTime,
            );
            print("⏰ Scheduled: ${data['title']} at $dateTime");
          }
        }
      }
    });
  }
  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'medication': return FontAwesomeIcons.pills;
      case 'hygiene': return FontAwesomeIcons.tooth;
      case 'ice_pack': return FontAwesomeIcons.snowflake;
      case 'refill': return FontAwesomeIcons.flask;
      default: return FontAwesomeIcons.bell;
    }
  }

  Future<void> _markAsDone(String docId) async {
    await remindersRef.doc(docId).update({
      'isDone': true,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // إلغاء الإشعار عند الضغط على Done
    NotificationHelper.cancelNotification(docId.hashCode.abs());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Great job! Reminder completed."),
        backgroundColor: accentBlue,
        behavior: SnackBarBehavior.floating,
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
          icon:  Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
        ),
        title: const Text(
          "My Reminders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          // زر لاختبار الإشعارات (يظهر إشعار بعد 5 ثواني)
          IconButton(
            icon: Icon(Icons.notification_add_outlined, color: accentBlue),
            onPressed: () {
              NotificationHelper.scheduleNotification(
                id: 999,
                title: "Test Reminder",
                body: "This is a test to verify notifications are working!",
                scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Test notification set for 5 seconds from now"))
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: remindersRef
            .where('patientId', isEqualTo: 'user_123')
            .where('isDone', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentBlue));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No upcoming reminders", style: TextStyle(color: Colors.white70))
            );
          }

          final reminders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              var data = reminders[index].data() as Map<String, dynamic>;
              String docId = reminders[index].id;

              Timestamp timestamp = data['scheduledTime'];
              DateTime dateTime = timestamp.toDate();
              String formattedTime = DateFormat('hh:mm a').format(dateTime);
              String formattedDate = DateFormat('MMM d, yyyy').format(dateTime);

              return _buildReminderItem(docId, data, formattedTime, formattedDate);
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
                child: Icon(_getIcon(data['iconType'] ?? 'bell'), color: accentBlue, size: 22),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        data['title'] ?? 'No Title',
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
                onPressed: () => _markAsDone(docId),
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(110, 48)
                ),
                child: Text(
                    "Done",
                    style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
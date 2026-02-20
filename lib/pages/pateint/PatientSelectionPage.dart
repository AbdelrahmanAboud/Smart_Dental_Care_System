import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_dental_care_system/pages/pateint/ChatBot.dart';
import 'package:smart_dental_care_system/pages/pateint/ChatScreen.dart';

class PatientSelectionPage extends StatelessWidget {
  const PatientSelectionPage({super.key});
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  void _goToChat(BuildContext context, String targetName, String targetId) {
    final String myId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    List<String> ids = [myId, targetId];
    ids.sort();
    String roomId = ids.join("_");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverName: targetName,
          chatId: roomId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  bgColor,
      appBar: AppBar(
        title: const Text(
          "Support Center",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text("How can we help you?",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Doctor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return  SizedBox();
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var doctorData = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildCard(
                          context,
                          title: "Dr. ${doctorData['name']}",
                          subtitle: "Medical questions ",
                          icon: Icons.medical_services_outlined,
                          color: const Color(0xFF00F5FF),
                          onTap: () => _goToChat(context, doctorData['name'], doc.id),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              _buildCard(
                context,
                title: "Reception Desk",
                subtitle: "Appointments & Booking",
                icon: Icons.support_agent_rounded,
                color: const Color(0xFF4361EE),
                onTap: () => _goToChat(context, "Reception", "receptionist_fixed_id"),
              ),

              const SizedBox(height: 20),

              _buildCard(
                context,
                title: "AI Dental Assistant",
                subtitle: "Instant answers & Care tips",
                icon: Icons.auto_awesome,
                color: const Color(0xFFAD62FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBot(
                        receiverName: "AI Assistant",
                        chatId: "ai_bot_room", // معرف خاص بالبوت
                        isAI: true, // هنضيف المتغير ده للكلاس
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
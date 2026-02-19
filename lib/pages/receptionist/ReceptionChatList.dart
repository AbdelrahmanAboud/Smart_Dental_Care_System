import 'dart:ui'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/pages/pateint/ChatScreen.dart';

class ReceptionChatList extends StatefulWidget {
  const ReceptionChatList({super.key});

  @override
  State<ReceptionChatList> createState() => _ReceptionChatListState();
}

class _ReceptionChatListState extends State<ReceptionChatList> {
  late Stream<DatabaseEvent> _receptionStream;

  @override
  void initState() {
    super.initState();
    _receptionStream = FirebaseDatabase.instance.ref().child('chats').onValue;
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF020408); 

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true, 
      appBar: _buildGlassAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020408)],
          ),
        ),
        child: StreamBuilder(
          stream: _receptionStream,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2EC4FF)));
            }

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              Map<dynamic, dynamic> chats = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              
              var receptionChats = chats.keys
                  .where((key) => key.toString().contains("receptionist"))
                  .toList();

              if (receptionChats.isEmpty) {
                return const Center(
                  child: Text("No Messages requests yet.", style: TextStyle(color: Colors.white24, fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 120, bottom: 20),
                itemCount: receptionChats.length,
                itemBuilder: (context, index) {
                  String roomId = receptionChats[index];
                  return _buildChatTile(context, roomId, chats);
                },
              );
            }
            return const Center(child: Text("No data found", style: TextStyle(color: Colors.white24)));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            title: const Text("Reception Desk", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            backgroundColor: Colors.white.withOpacity(0.03),
            elevation: 0,
            centerTitle: false,
            shape: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
          ),
        ),
      ),
    );
  }

 Widget _buildChatTile(BuildContext context, String roomId, Map<dynamic, dynamic> allData) {
  String patientUid = roomId
      .replaceAll("receptionist", "")
      .replaceAll("fixed_id", "") 
      .replaceAll("_", "")
      .trim();

  print("CLEANED UID: $patientUid");

  var messagesMap = allData[roomId]['messages'] as Map<dynamic, dynamic>?;
  String lastMsg = "New Inquiry";
  String lastTime = "";

  if (messagesMap != null) {
    var sortedKeys = messagesMap.keys.toList()
      ..sort((a, b) => (messagesMap[a]['timestamp'] ?? 0).compareTo(messagesMap[b]['timestamp'] ?? 0));
    lastMsg = messagesMap[sortedKeys.last]['text'] ?? "";
    lastTime = messagesMap[sortedKeys.last]['time'] ?? "";
  }

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(patientUid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 90,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(20)),
        );
      }

      var userData = snapshot.data?.data() as Map<String, dynamic>?;
      String patientName = userData?['name'] ?? "Patient";
      String imageUrl = userData?['profileImage'] ?? "";

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2EC4FF).withOpacity(0.1),
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty ? const Icon(Icons.person, color: Color(0xFF2EC4FF)) : null,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(patientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              Text(lastTime, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(receiverName: patientName, chatId: roomId)),
          ),
        ),
      );
    },
  );
}
}
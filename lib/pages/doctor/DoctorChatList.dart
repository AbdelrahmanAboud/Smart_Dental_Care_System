import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/pages/pateint/ChatScreen.dart';

class DoctorChatList extends StatefulWidget {
  const DoctorChatList({super.key});

  @override
  State<DoctorChatList> createState() => _DoctorChatListState();
}

class _DoctorChatListState extends State<DoctorChatList> {
  late Stream<DatabaseEvent> _chatsStream;
  String? myDoctorUid;

  @override
  void initState() {
    super.initState();
    myDoctorUid = FirebaseAuth.instance.currentUser?.uid;
    
    _chatsStream = FirebaseDatabase.instance.ref().child('chats').onValue;
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0B1C2D);

    // لو الـ UID لسه مجهزاش بنظهر دائرة تحميل بسيطة
    if (myDoctorUid == null) {
      return Scaffold(backgroundColor: bgColor, body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Patient Messages", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _chatsStream, 

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2EC4FF)));
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> chats = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            
            var myChats = chats.keys
                .where((key) => key.toString().contains(myDoctorUid!))
                .toList();

            if (myChats.isEmpty) {
              return const Center(child: Text("No messages yet.", style: TextStyle(color: Colors.white24)));
            }

            return ListView.builder(
              itemCount: myChats.length,
              itemBuilder: (context, index) {
                String roomId = myChats[index];
        return _buildPatientTile(context, roomId, chats, myDoctorUid!);          
    },
            );
          }
          return  Center(child: Text("No messages from patients yet.", style: TextStyle(color: Colors.white24)));
        },
      ),
    );
  }

  Widget _buildPatientTile(BuildContext context, String roomId, Map<dynamic, dynamic> allChatData, String myDoctorUid) {
  // 1. استخراج الـ UID للمريض من الـ Room ID
  String patientUid = roomId.replaceAll(myDoctorUid, "").replaceAll("_", "");

  // 2. جلب آخر رسالة ووقتها من الـ Realtime Database
  var messagesMap = allChatData[roomId]['messages'] as Map<dynamic, dynamic>?;
  String lastMessage = "No messages yet";
  String lastTime = "";

  if (messagesMap != null) {
    var sortedKeys = messagesMap.keys.toList()
      ..sort((a, b) => (messagesMap[a]['timestamp'] ?? 0).compareTo(messagesMap[b]['timestamp'] ?? 0));
    
    var lastMsgData = messagesMap[sortedKeys.last];
    lastMessage = lastMsgData['text'] ?? "";
    lastTime = lastMsgData['time'] ?? "";
  }

  // 3. جلب بيانات المريض (الاسم والصورة) من Firestore
return FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance.collection('users').doc(patientUid).get(),
  builder: (context, snapshot) {
    // حالة الانتظار: بنعرض هيكل كارت شفاف عشان الشاشة متبقاش فاضية (Shimmer Effect بسيط)
    if (!snapshot.hasData) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
        ),
      );
    }

    var userData = snapshot.data!.data() as Map<String, dynamic>?;
    // هنا بنجيب البيانات من Firestore بناءً على الشخص اللي باعت فعلاً
    String patientName = userData?['name'] ?? "Patient";
    String imageUrl = userData?['profileImage'] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // استخدام لون الكارت اللي في الصورة (داكن مع شفافية)
        color: const Color(0xFF1E293B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)), // حواف نحيفة جداً
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // الصورة الشخصية للمريض من الداتابيز
        leading: Hero(
          tag: 'avatar_$roomId', // أنيميشن سلس لما تفتح الشات
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2EC4FF).withOpacity(0.1),
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty 
                ? const Icon(Icons.person, color: Color(0xFF2EC4FF), size: 30) 
                : null,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                patientName, 
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
            Text(
              lastTime, 
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            lastMessage, // آخر رسالة مبعوثة
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 14),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverName: patientName, 
              chatId: roomId,
            ),
          ),
        ),
      ),
    );
  },
);
}
}
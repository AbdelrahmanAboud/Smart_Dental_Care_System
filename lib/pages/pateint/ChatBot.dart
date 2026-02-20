import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBot extends StatefulWidget {
  final String receiverName;
  final String chatId;
  final bool isAI;

  const ChatBot({
    super.key,
    required this.receiverName,
    required this.chatId,
    this.isAI = true,
  });

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // --- إعدادات جيميناي (تأكد من صلاحية المفتاح) ---
  final String _apiKey = "AIzaSyCwqOJncelvuQGd7p9k0GlBugwBEvVxGYo";

  late final DatabaseReference _dbRef = FirebaseDatabase.instance
      .ref()
      .child('chats')
      .child(widget.chatId)
      .child('messages');

  final Color aiThemeColor = const Color(0xFFAD62FF);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01080B),
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: aiThemeColor.withOpacity(0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: StreamBuilder(
                  stream: _dbRef.orderByChild('timestamp').onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      var sortedKeys = map.keys.toList()
                        ..sort((a, b) => (map[a]['timestamp'] ?? 0).compareTo(map[b]['timestamp'] ?? 0));

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          var msg = map[sortedKeys[index]];
                          bool isMe = msg['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                          return _buildMessageBubble(msg['text'], isMe, msg['time']);
                        },
                      );
                    }
                    return _buildWelcomeState();
                  },
                ),
              ),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.only(top: 50, left: 10, right: 20, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: aiThemeColor.withOpacity(0.2),
                child: Icon(Icons.auto_awesome, color: aiThemeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.receiverName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text("AI Assistant Active", style: TextStyle(color: aiThemeColor, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3B5BDB) : aiThemeColor.withOpacity(0.12),
          border: isMe ? null : Border.all(color: aiThemeColor.withOpacity(0.2)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 5),
            bottomRight: Radius.circular(isMe ? 5 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
            const SizedBox(height: 8),
            Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: aiThemeColor.withOpacity(0.3), size: 60),
          const SizedBox(height: 16),
          const Text("Hello! I'm your Dental AI Assistant.", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text("How can I help you with your teeth today?", style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 15),
      child: Row(
        children: [
          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: aiThemeColor)),
          const SizedBox(width: 12),
          Text("AI is thinking...", style: TextStyle(color: aiThemeColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF111418),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type your dental question...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              height: 55, width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [aiThemeColor, const Color(0xFF6366F1)]),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() async {
    if (_messageController.text.trim().isEmpty || _isTyping) return;

    final userMsg = _messageController.text.trim();
    _messageController.clear();

    await _dbRef.push().set({
      "text": userMsg,
      "senderId": FirebaseAuth.instance.currentUser?.uid,
      "timestamp": ServerValue.timestamp,
      "time": DateFormat('hh:mm a').format(DateTime.now()),
    });

    _scrollToBottom();
    _getGeminiResponse(userMsg);
  }

  void _getGeminiResponse(String userMsg) async {
    if (!mounted) return;
    setState(() => _isTyping = true);

    try {
      // يفضل استخدام gemini-1.5-flash لضمان الاستقرار مع الـ API Key الجديد
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );


      final prompt = [
        Content.text("""
        You are 'Smart Dental Assistant', an expert AI specialized in dentistry.
        
        INSTRUCTIONS:
        1. LANGUAGE: Always respond in the SAME language the user uses (Arabic or English).
        2. DISCLAIMER: If you provide any medical explanation, always end with: "Please note: This is an AI assessment, not a final diagnosis. Consult your dentist."
        3. EMERGENCY: If the user mentions severe swelling, difficulty breathing, or a knocked-out tooth, tell them to go to the Emergency Room (ER) IMMEDIATELY.
        4. DIAGNOSIS: When symptoms are described (like toothache), list 2-3 possible causes (e.g., cavity, gum infection, or wisdom tooth).
        5. PROCEDURES: If asked about 'whitening', 'implants', or 'braces', explain them simply and professionally.
        6. SCOPE: If the user asks about non-dental topics (politics, sports, etc.), politely say: "I am a dental specialist. I can only help you with oral health questions."
        
        Patient's Question: $userMsg
        """)
      ];

      final response = await model.generateContent(prompt);
      final aiResponse = response.text;

      if (aiResponse != null && mounted) {
        await _dbRef.push().set({
          "text": aiResponse,
          "senderId": "ai_bot",
          "timestamp": ServerValue.timestamp,
          "time": DateFormat('hh:mm a').format(DateTime.now()),
        });
      }
    } catch (e) {
      print("GEMINI ERROR: $e");
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
        _scrollToBottom();
      }
    }
  }
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }
}
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.receiverName,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final DatabaseReference _dbRef = FirebaseDatabase.instance
      .ref()
      .child('chats')
      .child(widget.chatId)
      .child('messages');

  String getPatientUid() {
    return widget.chatId
        .replaceAll(FirebaseAuth.instance.currentUser?.uid ?? "", "")
        .replaceAll("_", "")
        .replaceAll("receptionist", "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01080B),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F5FF).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
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
                    if (snapshot.hasData &&
                        snapshot.data!.snapshot.value != null) {
                      Map<dynamic, dynamic> map =
                          snapshot.data!.snapshot.value
                              as Map<dynamic, dynamic>;
                      var sortedKeys = map.keys.toList()
                        ..sort(
                          (a, b) => (map[a]['timestamp'] ?? 0).compareTo(
                            map[b]['timestamp'] ?? 0,
                          ),
                        );

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: sortedKeys.length,
                        itemBuilder: (context, index) {
                          var msg = map[sortedKeys[index]];
                          bool isMe =
                              msg['senderId'] ==
                              FirebaseAuth.instance.currentUser?.uid;
                          return _buildMessageBubble(
                            msg['text'],
                            isMe,
                            msg['time'],
                          );
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00F5FF),
                      ),
                    );
                  },
                ),
              ),
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
          padding: const EdgeInsets.only(
            top: 50,
            left: 20,
            right: 20,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(getPatientUid())
                    .get(),
                builder: (context, snapshot) {
                  String? imageUrl;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    imageUrl = data['profileImage'];
                  }
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1E293B),
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl == null || imageUrl.isEmpty)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.receiverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00F5FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "Online",
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // _buildAppBarAction(Icons.videocam_rounded),
              // const SizedBox(width: 10),
              // _buildAppBarAction(Icons.more_vert_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: Colors.white70, size: 22),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF3B5BDB) : const Color(0xFF1A1D23),
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
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.done_all,
                    color: Color(0xFF00F5FF),
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF111418),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 55,
              width: 55,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00F5FF), Color(0xFF4361EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.black,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();
    await _dbRef.push().set({
      "text": text,
      "senderId": FirebaseAuth.instance.currentUser?.uid,
      "timestamp": ServerValue.timestamp,
      "time": DateFormat('hh:mm a').format(DateTime.now()),
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

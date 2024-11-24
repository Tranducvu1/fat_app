import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatTeacherRoom extends StatefulWidget {
  final String chatRoomId; // Chat room identifier
  final String otherUserName; // Name of the other user in the chat

  const ChatTeacherRoom({
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  _ChatTeacherRoomState createState() => _ChatTeacherRoomState();
}

class _ChatTeacherRoomState extends State<ChatTeacherRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String username = ''; // Current user's username

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget is initialized
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  /// Fetches and sets the current user's username from Firestore
  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            username = doc.get('username') as String? ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Sends a text message to the chat
  Future<void> onSendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tin nhắn không được để trống")),
      );
      return;
    }

    final messageData = {
      "sendby": username,
      "message": _messageController.text.trim(),
      "type": "text",
      "time": FieldValue.serverTimestamp(),
    };

    _messageController.clear(); // Clear the text field after sending

    try {
      await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messageData);
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  /// Builds the chat screen UI
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.person),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatrooms')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Không có tin nhắn nào"));
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    return _buildMessageBubble(size, messageData);
                  },
                );
              },
            ),
          ),
          // Message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: onSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single message bubble
  Widget _buildMessageBubble(Size size, Map<String, dynamic> messageData) {
    // Format the timestamp to a readable time
    final timestamp = messageData['time'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : 'Đang gửi';

    // Determine if the message is sent by the current user
    final isMe = messageData['sendby'] == username;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(15),
              ),
            ),
            child: Text(
              messageData['message'],
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

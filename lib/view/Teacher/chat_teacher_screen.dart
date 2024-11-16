import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatTeacherRoom extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  ChatTeacherRoom({required this.chatRoomId, required this.otherUserName});

  @override
  _ChatTeacherRoomState createState() => _ChatTeacherRoomState();
}

class _ChatTeacherRoomState extends State<ChatTeacherRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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
      print('Error loading user data: $e');
    }
  }

  void onSendMessage() async {
    if (_message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tin nhắn không được để trống")),
      );
      return;
    }

    Map<String, dynamic> messages = {
      "sendby": username,
      "message": _message.text.trim(),
      "type": "text",
      "time": FieldValue.serverTimestamp(),
    };

    _message.clear();

    try {
      await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person),
              backgroundColor: Colors.blue,
            ),
            SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
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
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Không có tin nhắn nào"));
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;
                    return buildMessage(size, messageData);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _message,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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

  Widget buildMessage(Size size, Map<String, dynamic> messageData) {
    Timestamp? timestamp = messageData['time'] as Timestamp?;
    String formattedTime = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : 'Đang gửi';

    bool isMe = messageData['sendby'] == username;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: isMe ? Radius.circular(15) : Radius.zero,
                bottomRight: isMe ? Radius.zero : Radius.circular(15),
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
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

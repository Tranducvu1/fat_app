import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/Teacher/chat_teacher_screen.dart';

class TutorChatRoomsPage extends StatefulWidget {
  @override
  _TutorChatRoomsPageState createState() => _TutorChatRoomsPageState();
}

class _TutorChatRoomsPageState extends State<TutorChatRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getChatRoomIds();
  }

  void getChatRoomIds() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      QuerySnapshot snapshot = await _firestore.collection('chatrooms').get();
      for (DocumentSnapshot doc in snapshot.docs) {
        String chatRoomId = doc.id;
        print('Chat Room ID: $chatRoomId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chat Rooms"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Unable to load user information"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Rooms"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chatrooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading chat rooms"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chat rooms available"));
          }

          var chatRooms = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              String chatRoomId = chatRooms[index].id;
              List<dynamic> members = chatRoom['members'];
              String otherUserName =
                  members.firstWhere((member) => member != currentUserId);

              return Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatTeacherRoom(
                          chatRoomId: chatRoomId,
                          otherUserName: otherUserName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      otherUserName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

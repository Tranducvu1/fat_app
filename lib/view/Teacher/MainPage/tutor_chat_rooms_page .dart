import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/Teacher/Chatroom/chat_teacher_screen.dart';

class TutorChatRoomsPage extends StatefulWidget {
  @override
  _TutorChatRoomsPageState createState() => _TutorChatRoomsPageState();
}

class _TutorChatRoomsPageState extends State<TutorChatRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser?.uid ?? '';

    // If the user is not authenticated, show a fallback UI
    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/teachercourse');
            },
          ),
          title: const Text("Chat Rooms"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Unable to load user information"),
        ),
      );
    }

    // Main UI with chat room list
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Rooms"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chatrooms')
            .where('members',
                arrayContains: currentUserId) // Only fetch relevant chatrooms
            .snapshots(),
        builder: (context, snapshot) {
          // Show a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading chat rooms"),
            );
          }

          // Show a message if no chat rooms are available
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chat rooms available"));
          }

          // Extract chat room data
          var chatRooms = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              var chatRoom = chatRooms[index].data() as Map<String, dynamic>;
              String chatRoomId = chatRooms[index].id;
              List<dynamic> members = chatRoom['members'] ?? [];
              String otherUserName = members.firstWhere(
                (member) => member != currentUserId,
                orElse: () => 'Unknown User',
              );

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
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            otherUserName.isNotEmpty
                                ? otherUserName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          otherUserName,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

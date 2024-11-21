// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fat_app/view/Student/Chatroom/chat_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatRoomsPage extends StatefulWidget {
//   @override
//   _ChatRoomsPageState createState() => _ChatRoomsPageState();
// }

// class _ChatRoomsPageState extends State<ChatRoomsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     getChatRoomIds();
//   }

//   void getChatRoomIds() async {
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId != null) {
//       QuerySnapshot snapshot = await _firestore.collection('chatrooms').get();
//       for (DocumentSnapshot doc in snapshot.docs) {
//         String chatRoomId = doc.id;
//         print('Chat Room ID: $chatRoomId');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String currentUserId = _auth.currentUser?.uid ?? '';

//     if (currentUserId.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text("Chat Rooms"),
//         ),
//         body: const Center(
//           child: Text("Unable to load user information"),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat Rooms"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('chatrooms').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text("Error loading chat rooms"),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No chat rooms available"));
//           }

//           var chatRooms = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: chatRooms.length,
//             itemBuilder: (context, index) {
//               var chatRoom = chatRooms[index].data() as Map<String, dynamic>;
//               String chatRoomId = chatRooms[index].id;
//               List<dynamic> members = chatRoom['members'];
//               String otherUserName =
//                   members.lastWhere((member) => member != currentUserId);

//               return Card(
//                 elevation: 4.0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     child: Text(
//                       otherUserName.substring(0, 1).toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     "Chat with $otherUserName",
//                     style: const TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: const Text(
//                     "Click to join the chat",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 14.0,
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatRoom(
//                           chatRoomId: chatRoomId,
//                           userMap: {},
//                           otherUserName: otherUserName,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/view/Student/Chatroom/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomsPage extends StatefulWidget {
  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _getChatRooms();
  }

  void _getChatRooms() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      QuerySnapshot snapshot = await _firestore.collection('chatrooms').get();
      _chatRooms = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final members = data['members'] as List<dynamic>;
        final otherUserName =
            members.lastWhere((member) => member != currentUserId);
        return {
          'chatRoomId': doc.id,
          'otherUserName': otherUserName,
          'memberCount': members.length,
          'lastMessageTime': data['last_message_time'] ?? 'No messages',
        };
      }).toList();
      _chatRooms
          .sort((a, b) => a['otherUserName'].compareTo(b['otherUserName']));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Chat Rooms"),
        ),
        body: const Center(
          child: Text("Unable to load user information"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Rooms"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: _chatRooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = _chatRooms[index];
                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        chatRoom['otherUserName']
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "Chat with ${chatRoom['otherUserName']}",
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${chatRoom['memberCount']} members | Last message: ${chatRoom['lastMessageTime']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoom(
                            chatRoomId: chatRoom['chatRoomId'],
                            userMap: {},
                            otherUserName: chatRoom['otherUserName'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

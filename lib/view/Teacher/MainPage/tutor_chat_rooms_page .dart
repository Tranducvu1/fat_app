import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fat_app/view/Teacher/Chatroom/chat_teacher_screen.dart';

class TutorChatRoomsPage extends StatefulWidget {
  @override
  _TutorChatRoomsPageState createState() => _TutorChatRoomsPageState();
}

class _TutorChatRoomsPageState extends State<TutorChatRoomsPage> {
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
            members.firstWhere((member) => member != currentUserId);
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

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('GPS is disabled. Enable it to share location.')),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied.')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamed('/teachercourse');
          },
        ),
        title: Text("Chat Rooms"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'share_location') {
                          final position = await _getCurrentLocation();
                          if (position != null) {
                            final locationUrl =
                                'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Location: $locationUrl')),
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'share_location',
                            child: Text('Share Location'),
                          ),
                        ];
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatTeacherRoom(
                            chatRoomId: chatRoom['chatRoomId'],
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

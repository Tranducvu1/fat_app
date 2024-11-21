import 'package:fat_app/Model/UserModel.dart';
import 'package:fat_app/view/Student/Chatroom/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TutorDetailPage extends StatefulWidget {
  final Course course;
  final UserModel user;

  const TutorDetailPage({Key? key, required this.course, required this.user})
      : super(key: key);

  @override
  State<TutorDetailPage> createState() => _TutorDetailPageState();
}

class _TutorDetailPageState extends State<TutorDetailPage> {
  bool isFavorite = false;
  bool isLoading = true;
  String teacherUsername = '';
  String username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    getUserData();
    _loadUserData();
  }

  Future<void> _loadTeacherData() async {
    try {
      QuerySnapshot teacherDoc = await _firestore
          .collection('Users')
          .where("username", isEqualTo: widget.course.teacher)
          .limit(1)
          .get();
      if (teacherDoc.docs.isNotEmpty) {
        setState(() {
          teacherUsername = teacherDoc.docs[0].get('username') as String;
          userMap = {
            ...teacherDoc.docs[0].data() as Map<String, dynamic>,
            'uid': teacherDoc.docs[0].id,
          };
        });
      }
    } catch (e) {
      print('Error loading teacher data: $e');
    }
  }

  void getUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _firestore
          .collection('Users')
          .where("username", isEqualTo: widget.user.userName)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            userMap = {
              ...value.docs[0].data(),
              'uid': value.docs[0].id,
            };
            isLoading = false;
          });
        } else {
          createUserDocument();
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void createUserDocument() async {
    try {
      Map<String, dynamic> userData = {
        'username': widget.user.userName,
        'email': widget.user.email,
        'uid': _firestore.collection('Users').doc().id,
        'status': 'Offline',
        'position': widget.user.position,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userData['uid']).set(userData);

      setState(() {
        userMap = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating user: $e')),
      );
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
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

  void startChat() async {
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set your display name first')),
      );
      return;
    }

    if (teacherUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find teacher information')),
      );
      return;
    }

    try {
      String roomId = chatRoomId(username, teacherUsername);

      DocumentSnapshot chatRoom =
          await _firestore.collection('chatrooms').doc(roomId).get();

      if (!chatRoom.exists) {
        await _firestore.collection('chatrooms').doc(roomId).set({
          'members': [username, teacherUsername],
          'created_at': FieldValue.serverTimestamp(),
          'last_message': null,
          'last_message_time': null,
          'course_id': widget.course.id,
        });
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatRoom(
            chatRoomId: roomId,
            userMap: {
              'username': teacherUsername,
              'email': userMap?['email'] ?? '',
              'uid': userMap?['uid'] ?? '',
              'status': userMap?['status'] ?? 'Offline'
            },
            otherUserName: '',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.userName),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'avatar-${widget.user.userName}',
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('images/avata.jpg'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Teacher: $teacherUsername',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subject: ${widget.course.subject}',
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Position: ${widget.user.position}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description: ${widget.course.description}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Phone: ${widget.user.phoneNumber}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Time: ${widget.course.startDate} - ${widget.course.endDate}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: startChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Inbox',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '4.5/5',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Implement review functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Write a Review',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

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
        title: Text("${widget.user.userName}"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('images/avata.jpg'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          teacherUsername,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Science Teacher",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                                5,
                                (index) => Icon(
                                      index < 4 ? Icons.star : Icons.star_half,
                                      color: Colors.amber,
                                      size: 20,
                                    )),
                            const SizedBox(width: 8),
                            const Text(
                              "4.5/5",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Information Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        //subject
                        InformationRow(
                          icon: Icons.book_outlined,
                          title: "Subject",
                          content: widget.course.subject,
                        ),
                        // Location
                        InformationRow(
                          icon: Icons.location_on_outlined,
                          title: "Location",
                          content: widget.user.position,
                        ),
                        const SizedBox(height: 16),

                        // Available Time
                        InformationRow(
                          icon: Icons.calendar_today_outlined,
                          title: "Available Time",
                          content:
                              "${widget.course.startDate} - ${widget.course.endDate}",
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        InformationRow(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          content: widget.user.phoneNumber,
                        ),
                      ],
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: startChat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Inbox',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Implement review functionality
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Write a Review',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InformationRow({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.black54),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/ultilities/Show_Error_Dialog.dart';
import 'package:fat_app/view/Student/Chapter/list_lecture_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fat_app/view/widgets/search_bar.dart';
import 'package:fat_app/view/widgets/subject_chips.dart';
import 'package:fat_app/view/widgets/navigation/custom_app_bar.dart';
import 'package:fat_app/view/widgets/navigation/custom_bottom_navigation_bar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key, required this.course}) : super(key: key);
  final Course course;

  @override
  _CoursePage createState() => _CoursePage();
}

class _CoursePage extends State<CoursePage> with TickerProviderStateMixin {
  String username = '';
  String creatorEmail = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Course> courses = [];
  List<String> registeredCourses = [];

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fetchCourses();
    _fetchRegisteredCourses();
    _loadUserData();
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

  Future<void> _fetchCourses() async {
    try {
      final result = await _firestore.collection('Courses').get();
      setState(() {
        courses =
            result.docs.map((doc) => Course.fromDocumentSnapshot(doc)).toList();
      });

      // Fetch creator email for each course
      for (var course in courses) {
        creatorEmail = await _getCreatorEmail(
            course.id); // Pass course.id to get creator's email
        print('Creator email for course ${course.subject}: $creatorEmail');
      }
    } catch (e) {
      print('Failed to fetch courses: $e');
    }
  }

  Future<String> _getCreatorEmail(String courseId) async {
    try {
      // Fetch all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      // Loop through each user and check if the user has the role 'Teacher' and if the user created the course
      for (var userDoc in usersSnapshot.docs) {
        // Check if the user is a Teacher and has the createdCourses field
        if (userDoc.data().containsKey('rool') &&
            userDoc.get('rool') == 'Teacher' &&
            userDoc.data().containsKey('createdCourses')) {
          // Get the list of created courses
          List<dynamic> createdCourses = userDoc.get('createdCourses') ?? [];

          // Check if the course ID is in the list of created courses
          if (createdCourses.contains(courseId)) {
            // Return the email of the teacher
            final email = userDoc.get('email') as String? ?? '';
            return email;
          }
        }
      }

      return 'No email found'; // If no creator is found
    } catch (e) {
      print('Error getting creator email: $e');
      return 'Error retrieving email';
    }
  }

  Future<void> _fetchRegisteredCourses() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        setState(() {
          registeredCourses =
              List<String>.from(userDoc.data()?['registeredCourses'] ?? []);
        });
      } catch (e) {
        print('Failed to fetch registered courses: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        username: username,
        onAvatarTap: () {
          Navigator.of(context).pushNamed('/updateinformation');
        },
        onNotificationTap: () {},
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SearchBarWidget(
                  onSearch: (query) {
                    print("Search query: $query");
                  },
                ),
                const SizedBox(height: 12.0),
                const SubjectChipsWidget(
                  subjects: [
                    'Chemistry',
                    'Physics',
                    'Math',
                    'Geography',
                    'History',
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.lightBlue.shade100,
            padding: const EdgeInsets.all(16.0),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Schedule Courses',
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                bool isRegistered = registeredCourses.contains(course.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    height: 320,
                    child: _buildClassCard(
                      course.subject,
                      course.teacher,
                      '${course.startDate} - ${course.endDate}',
                      course.price,
                      course.description,
                      isRegistered,
                      course.id as String,
                      course,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed('/interactlearning');
              break;
            case 1:
              Navigator.of(context).pushNamed('/classschedule');
              break;
            case 2:
              Navigator.of(context).pushNamed('/course');
              break;
            case 3:
              Navigator.of(context).pushNamed('/chat');
              break;
            case 4:
              Navigator.of(context).pushNamed('/findatutor');
              break;
          }
        },
      ),
    );
  }

  Widget _buildClassCard(
    String subject,
    String teacher,
    String time,
    double price,
    String description,
    bool isRegistered,
    String creatorId,
    Course course,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 20, // Tăng kích thước chữ
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 18, // Tăng kích thước icon
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          teacher,
                          style: TextStyle(
                            fontSize: 16, // Tăng kích thước chữ
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .where('registeredCourses', arrayContains: creatorId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        int studentCount = snapshot.data!.docs.length;
                        return Row(
                          children: [
                            const Icon(
                              Icons.group,
                              size: 18, // Tăng kích thước icon
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$studentCount students enrolled',
                              style: TextStyle(
                                fontSize: 16, // Tăng kích thước chữ
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18, // Tăng kích thước icon
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 16, // Tăng kích thước chữ
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 15, // Tăng kích thước chữ
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: isRegistered
                          ? ElevatedButton.icon(
                              onPressed: () {
                                if (course.chapterId.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => LectureListScreen(
                                        chapterId: course.chapterId
                                            .map(int.parse)
                                            .toList(),
                                        course: course,
                                      ),
                                    ),
                                  );
                                } else {
                                  Show_Error_Dialog(context,
                                      "This course has no chapter yet");
                                }
                              },
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Join Course'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16), // Tăng padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                _showConfirmationDialog(
                                  context,
                                  price,
                                  creatorId,
                                  subject,
                                );
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label:
                                  Text('Buy for \$${price.toStringAsFixed(2)}'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    double price,
    String creatorId,
    String subject,
  ) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Purchase'),
            content: Text(
                'You confirm the purchase of the course at the price \$$price?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Không'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Có'),
                onPressed: () async {
                  try {
                    Navigator.of(dialogContext).pop();

                    if (context.mounted) {
                      Navigator.of(context).pushNamed(
                        '/payment',
                        arguments: {
                          'email': creatorEmail,
                          'price': price,
                          'courseId': creatorId,
                          'subject': subject,
                          'username': username,
                        },
                      );
                    }
                  } catch (e) {
                    print('Error in confirmation dialog: $e');
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing confirmation dialog: $e');
    }
  }
}

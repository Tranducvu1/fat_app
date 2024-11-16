import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/ultilities/Show_Error_Dialog.dart';
import 'package:fat_app/view/Student/list_lecture_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fat_app/view/widgets/search_bar.dart';
import 'package:fat_app/view/widgets/subject_chips.dart';
import 'package:fat_app/view/widgets/custom_app_bar.dart';
import 'package:fat_app/view/widgets/custom_bottom_navigation_bar.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key, required this.course}) : super(key: key);
  final Course course;

  @override
  _CoursePage createState() => _CoursePage();
}

class _CoursePage extends State<CoursePage> {
  String username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Course> courses = [];
  List<String> registeredCourses = [];

  @override
  void initState() {
    super.initState();
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
    } catch (e) {
      print('Failed to fetch courses: $e');
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

  Future<void> _registerCourse(String courseId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('Users').doc(user.uid).update({
          'registeredCourses': FieldValue.arrayUnion([courseId]),
        });
        _fetchRegisteredCourses();
      } catch (e) {
        print('Failed to register course: $e');
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
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
              children: courses.map((course) {
                bool isRegistered = registeredCourses.contains(course.id);
                return _buildClassCard(
                  course.subject,
                  course.teacher,
                  '${course.startDate} - ${course.endDate}',
                  course.price,
                  course.description,
                  isRegistered,
                  course.id as String,
                  course, // Passing the course to the method
                );
              }).toList(),
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
    Course course, // Passing the full course object
  ) {
    return Card(
      elevation: 4,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          teacher,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: isRegistered
                          ? ElevatedButton.icon(
                              onPressed: () {
                                print('course.chapterId: ${course.chapterId}');
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                    const EdgeInsets.symmetric(vertical: 12),
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
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text('Bạn xác nhận mua khóa học với giá \$$price?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                _registerCourse(creatorId);
                Navigator.of(context).pushNamed(
                  '/payment',
                  arguments: {
                    'price': price,
                    'courseId': creatorId,
                    'subject': subject,
                    'username': username,
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

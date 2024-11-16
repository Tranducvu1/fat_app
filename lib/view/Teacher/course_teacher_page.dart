import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/view/Teacher/add_courses_screen.dart';
import 'package:fat_app/view/Teacher/list_lecture_page.dart';
import 'package:fat_app/view/widgets/custom_teacher_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fat_app/view/widgets/search_bar.dart';
import 'package:fat_app/view/widgets/subject_chips.dart';
import 'package:fat_app/view/widgets/custom_app_bar.dart';

class courseteacherPage extends StatefulWidget {
  const courseteacherPage({Key? key, required this.course}) : super(key: key);
  final Course course;

  @override
  _CoursePage createState() => _CoursePage();
}

class _CoursePage extends State<courseteacherPage> {
  String username = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Course> courses = [];
  List<String> createdCourses = [];
  bool isLoading = true;
  String? _searchQuery;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Get user document
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        print('Lấy thông tin khóa học từ người dùng : $userDoc');
        if (userDoc.exists) {
          // Get username and email
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            username = userData['username'] as String? ?? '';
          });

          // Safely get created courses list
          var coursesData = userData['createdCourses'];
          List<String> courseIds = [];

          if (coursesData != null) {
            if (coursesData is List) {
              courseIds = coursesData.map((e) => e.toString()).toList();
            }
          }

          // Fetch full course details for each course ID
          List<Course> fetchedCourses = [];
          for (String courseId in courseIds) {
            try {
              DocumentSnapshot courseDoc =
                  await _firestore.collection('Courses').doc(courseId).get();

              if (courseDoc.exists) {
                Course course = Course.fromDocumentSnapshot(courseDoc);
                if (_shouldIncludeCourse(course)) {
                  fetchedCourses.add(course);
                }
              }
            } catch (e) {
              print('Error fetching course $courseId: $e');
              // Continue with the next course even if one fails
              continue;
            }
          }

          setState(() {
            courses = fetchedCourses;
            createdCourses = courseIds;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data and courses: $e');
      setState(() {
        isLoading = false;
      });
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading courses. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _shouldIncludeCourse(Course course) {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      if (!course.subject.toLowerCase().contains(query) &&
          !course.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    if (_selectedSubject != null && _selectedSubject!.isNotEmpty) {
      if (course.subject != _selectedSubject) {
        return false;
      }
    }

    return true;
  }

  Future<void> _refreshCourses() async {
    await _loadUserData();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadUserData();
  }

  void _handleSubjectFilter(String subject) {
    setState(() {
      _selectedSubject = subject == _selectedSubject ? null : subject;
    });
    _loadUserData();
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
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        child: Column(
          children: [
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchBarWidget(
                    onSearch: _handleSearch,
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
                  'My Courses',
                  style: TextStyle(fontSize: 24, color: Colors.blue),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery != null || _selectedSubject != null
                                    ? 'No courses match your search'
                                    : 'No courses created yet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(16.0),
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.7,
                          children: courses.map((course) {
                            return _buildClassCard(
                              course.subject,
                              course.teacher,
                              '${course.startDate} - ${course.endDate}',
                              course.price,
                              course.description,
                              true,
                              course.id as String,
                              course,
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddCoursesScreen()),
          );
          if (result == true) {
            _refreshCourses();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationTeacherBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamed('/teacherinteractlearning');
              break;
            case 1:
              Navigator.of(context).pushNamed('/teacherclassschedule');
              break;
            case 2:
              Navigator.of(context).pushNamed('/teachercourse');
              break;
            case 3:
              Navigator.of(context).pushNamed('/teacherchat');
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
    bool isCreator,
    String courseId,
    Course course,
  ) {
    return GestureDetector(
      onTap: () {
        if (course.chapterId.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LectureListTeacherScreen(
                chapterId: course.chapterId.map(int.parse).toList(),
                course: course,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Lectures Available'),
              content:
                  const Text('No lectures have been added to this course yet.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Card(
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
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${price.toStringAsFixed(2)} VND',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
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
                      if (isCreator)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Implement edit functionality
                              },
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Course'),
                                    content: const Text(
                                      'Are you sure you want to delete this course?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  try {
                                    // Delete course from Courses collection
                                    await _firestore
                                        .collection('Courses')
                                        .doc(courseId)
                                        .delete();

                                    // Remove course ID from user's createdCourses
                                    final user = _auth.currentUser;
                                    if (user != null) {
                                      await _firestore
                                          .collection('Users')
                                          .doc(user.uid)
                                          .update({
                                        'createdCourses':
                                            FieldValue.arrayRemove([courseId])
                                      });
                                    }

                                    _refreshCourses();
                                  } catch (e) {
                                    print('Error deleting course: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to delete course. Please try again.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

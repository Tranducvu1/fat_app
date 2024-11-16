import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/view/widgets/custom_app_bar.dart';
import 'package:fat_app/view/widgets/custom_teacher_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/widgets/search_bar.dart';
import 'package:fat_app/view/widgets/subject_chips.dart';

class classscheduleteacherPage extends StatefulWidget {
  const classscheduleteacherPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassSchedulePage();
}

class _ClassSchedulePage extends State<classscheduleteacherPage> {
  String username = '';
  int currentIndex = 1;
  final List<String> subjects = [
    'Chemistry',
    'Physics',
    'Math',
    'Geography',
    'History',
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        username: username,
        onAvatarTap: () =>
            Navigator.of(context).pushNamed('/updateinformation'),
        onNotificationTap: () {},
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchBarWidget(
                    onSearch: (query) {
                      print("Search query: $query");
                    },
                  ),
                  const SizedBox(height: 16.0),
                  SubjectChipsWidget(subjects: subjects),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tran Duc Vu! Keep up the great work! 🌟',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Classes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildClassCard(
                'Mathematics',
                'Mr. John Smith',
                '18:30 - 21:00',
                'Wednesday',
                Colors.blue[100]!,
                Icons.functions,
              ),
              _buildClassCard(
                'Physics',
                'Dr. Sarah Wilson',
                '14:00 - 16:30',
                'Monday',
                Colors.purple[100]!,
                Icons.science,
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationTeacherBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _navigateToPage(index);
        },
      ),
    );
  }

  Widget _buildClassCard(String subject, String teacher, String time,
      String day, Color backgroundColor, IconData subjectIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [backgroundColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor.withOpacity(0.3),
              child: Icon(subjectIcon, color: backgroundColor.withOpacity(0.8)),
            ),
            title: Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '$time • $day',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          teacher,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: 'Assignments'),
                              Tab(text: 'Documents'),
                              Tab(text: 'Comments'),
                            ],
                          ),
                          Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: TabBarView(
                              children: [
                                _buildEmptyState(
                                  'No assignments yet',
                                  Icons.assignment,
                                ),
                                _buildEmptyState(
                                  'No documents uploaded',
                                  Icons.description,
                                ),
                                _buildEmptyState(
                                  'No comments yet',
                                  Icons.chat_bubble_outline,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    final routes = [
      '/teacherinteractlearning',
      '/teacherclassschedule',
      '/teachercourse',
      '/teacherchat',
    ];
    if (index >= 0 && index < routes.length) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }
}

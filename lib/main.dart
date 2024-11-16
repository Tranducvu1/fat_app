import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/view/Student/chat_rooms_page.dart';
import 'package:fat_app/view/Student/list_lecture_page.dart';
import 'package:fat_app/view/Student/tutor_list_page.dart';
import 'package:fat_app/view/Teacher/tutor_chat_rooms_page%20.dart';
import 'package:fat_app/view/Teacher/class_schedule_page.dart';
import 'package:fat_app/view/Teacher/Interact_learning_teacher_page.dart';
import 'package:fat_app/view/Teacher/course_teacher_page.dart';
import 'package:fat_app/view/introduction_screen.dart';
import 'package:fat_app/view/payment/confirm_method_screen.dart';
import 'package:fat_app/view_auth/EmailVerify.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:fat_app/view_auth/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/update_Information_page.dart';
import 'package:fat_app/view/liveStreamPage.dart';
import 'package:fat_app/view/Student/class_schedule_page.dart';
import 'package:fat_app/view/Student/course_page.dart';
import 'package:fat_app/view/Student/interact_learning_page.dart';
import 'constants/routes.dart';
import 'package:google_fonts/google_fonts.dart';
// List<CameraDescrifption>? cameras;

Future<void> main() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCiwggXPtUAGNoyweoUyrfYRgv2fx2GrGw",
            authDomain: "study-86d58.firebaseapp.com",
            projectId: "study-86d58",
            storageBucket: "study-86d58.firebasestorage.app",
            messagingSenderId: "988979923331",
            appId: "1:988979923331:web:01192e3ea977b9cdf0ceb6",
            measurementId: "G-7748LM21HT"));
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  // cameras = await availableCameras();
  //WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      livestreampage: (context) => LiveStreamPage(),
      classschedulePage: (context) => const ClassSchedulePage(),
      coursepage: (context) => CoursePage(
            course: Course(
              id: '',
              subject: '',
              teacher: '',
              startDate: '',
              endDate: '',
              price: 0.0,
              description: '',
              creatorId: '',
              createdAt: Timestamp.now(),
              chapterId: [],
            ),
          ),

      fatutorpage: (context) => const TutorListPage(),
      interactlearningpage: (context) => const InteractLearningPage(),
      loginRoutes: (context) => LoginPage(),
      registerRoutes: (context) => Register(),
      emailverifyRoute: (context) => const EmailVerify(),
      paymentRoutes: (context) => PaymentMethodScreen(),
      updateinformationRoutes: (context) => UpdateInformationPage(),
      interactlearninteachergpage: (context) =>
          const InteractLearningTeacherPage(),
      chatpage: (context) => ChatRoomsPage(),
      chatteacherPage: (context) => TutorChatRoomsPage(),
      classscheduleteacherpage: (context) => const classscheduleteacherPage(),
      courseteacherpage: (context) => courseteacherPage(
            course: Course(
              id: '',
              subject: '',
              teacher: '',
              startDate: '',
              endDate: '',
              price: 0.0,
              description: '',
              creatorId: '',
              createdAt: Timestamp.now(),
              chapterId: [],
            ),
          ),
      // teacherliverecord: (context) => TeacherScreen(
      //       lessonId: 0,
      //     ),
      listlectureRoutes: (context) => LectureListScreen(
            chapterId: [0],
            course: Course(
              id: '',
              subject: '',
              teacher: '',
              startDate: '',
              endDate: '',
              price: 0.0,
              description: '',
              creatorId: '',
              createdAt: Timestamp.now(),
              chapterId: ['0'],
            ),
          ),
      // teacherlive: (context) => TeacherScreenLive(cameras: cameras!),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                height: screenSize.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF27AE60),
                      Color(0xFFD5F5E3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Circular decorations
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Logo and Title
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'images/factutor_logo.png',
                              width: screenSize.width * 0.4,
                              height: screenSize.width * 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Features Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Why Choose Us?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._buildFeatureItems(),
                  ],
                ),
              ),

              // Call to Action Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                        onPressed: () {
                          // Add navigation to login page
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    final features = [
      {
        'icon': Icons.access_time_rounded,
        'title': 'Flexible Learning',
        'description': 'Study at your own pace, anywhere and anytime',
      },
      {
        'icon': Icons.person_rounded,
        'title': 'Expert Tutors',
        'description': 'Learn from experienced and qualified teachers',
      },
      {
        'icon': Icons.computer_rounded,
        'title': 'Interactive Platform',
        'description': 'Engage in dynamic online learning experiences',
      },
      {
        'icon': Icons.chat_rounded,
        'title': 'Live Support',
        'description': 'Get help when you need it through live chat',
      },
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: const Color(0xFF27AE60),
                size: 28,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                feature['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ),
            subtitle: Text(
              feature['description'] as String,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

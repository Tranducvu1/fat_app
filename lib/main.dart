import 'package:fat_app/auth/auth_state_handler.dart';
import 'package:fat_app/constants/constant_routes.dart';
import 'package:fat_app/view/introduction_screen.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

// Main function to initialize Firebase and run the app
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  if (kIsWeb) {
    // final GoogleMapsFlutterPlatform mapsImplementation =
    //     GoogleMapsFlutterPlatform.instance;
    // if (mapsImplementation is GoogleMapsFlutterAndroid) {
    //   mapsImplementation.useAndroidViewSurface = true;
    //   // Tùy chọn: Cấu hình renderer
    //   await GoogleMapsFlutterAndroid.initializeWithRenderer(
    //       AndroidMapRenderer.latest);
    // }
    // // Initialize Firebase for web applications with specific options
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
    // Initialize Firebase for other platforms (like Android, iOS)
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  // Start the app by calling the AuthStateHandler widget
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    home: const AuthStateHandler(),
    routes: appRoutes,
  ));
}

// The HomePage widget is the main screen displayed after the app is initialized.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen
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
                    // Circular decorations for visual effect
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
                    // Logo and Title Section
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag:
                                'app_logo', // Hero animation for logo transition
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

              // Features Section with feature list
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
                    // Display the list of features
                    ..._buildFeatureItems(),
                  ],
                ),
              ),

              // Call to Action Button and Login Redirection
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the Onboarding screen
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
                          // Placeholder for navigation to login page
                        },
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the Login screen when tapped
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

  // Function to generate feature items for the "Why Choose Us?" section
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

    // Create a list of widgets for each feature
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

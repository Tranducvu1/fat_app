// Importing necessary packages and files for the app
import 'package:fat_app/main.dart';
import 'package:fat_app/view/introduction_screen.dart'; // Screen for onboarding/introduction
import 'package:fat_app/view/loading/loading_first_view.dart'; // Initial loading screen
// Screen for email verification
import 'package:fat_app/view_auth/login_view.dart'; // Login screen
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication SDK
import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:shared_preferences/shared_preferences.dart'; // For local key-value storage

// Main handler for authentication and navigation states
class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({Key? key}) : super(key: key);

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  bool _isFirstTime =
      true; // Tracks whether the app is opened for the first time

  @override
  void initState() {
    super.initState();
    _checkFirstTime(); // Initialize check for the first-time flag
  }

  // Asynchronously checks if it's the user's first time opening the app
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ??
          true; // Default to true if key is absent
    });
  }

  // Asynchronously sets the first-time flag to false after the initial app launch
  Future<void> _setFirstTimeFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // Persist data locally
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Observes auth state changes
      builder: (context, snapshot) {
        // Show loading screen while waiting for Firebase response
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingViewFirst();
        }
        // Navigate to onboarding if this is the first app launch
        if (_isFirstTime) {
          _setFirstTimeFalse(); // Update the first-time flag
          return HomePage(); // Show onboarding screen
        } else {
          // Navigate to login if no user is logged in
          return LoginPage();
        }
      },
    );
  }
}

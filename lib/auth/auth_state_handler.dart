import 'package:fat_app/view/loading/loading_view.dart';
import 'package:fat_app/view/update_Information_page.dart';
import 'package:fat_app/view_auth/EmailVerify.dart';
import 'package:fat_app/view_auth/login_view.dart';
import 'package:fat_app/view_auth/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the snapshot has user data
        if (snapshot.hasData) {
          // User is logged in, check email verification
          if (FirebaseAuth.instance.currentUser!.emailVerified) {
            // Navigate to the main content (you can change this to your desired page)
            return Register();
          } else {
            // Email not verified
            return const EmailVerify();
          }
        }
        // User is not logged in
        return LoginPage();
      },
    );
  }
}

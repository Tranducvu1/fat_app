import 'package:firebase_core/firebase_core.dart';
import 'package:fat_app/firebase_options.dart';
import 'package:fat_app/auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, FirebaseException;
import 'package:fat_app/auth/auth_exceptions.dart';
import 'package:fat_app/auth/auth_user.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider implements AuthProvider {
  final BuildContext context; // Thêm context để dùng cho SnackBar

  FirebaseAuthProvider({required this.context});

  @override
  Future<void> LogOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
    } else {
      throw UserNotLogInAuthException();
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully')),
        );
        return user;
      } else {
        throw UserNotLogInAuthException();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The password provided is too weak.')),
        );
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The account already exists for that email.')),
        );
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The email address is badly formatted.')),
        );
        throw InvalidEmailAuthException();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user. Please try again.')),
        );
        throw GenericAuthException();
      }
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );
        return user;
      } else {
        throw UserNotLogInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for that email.')),
        );
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong password provided.')),
        );
        throw WrongPasswordAuthException();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
        throw GenericAuthException();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVertification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      // Hiển thị thông báo gửi email thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email sent')),
      );
    } else {
      throw UserNotLogInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The email address is invalid.')),
          );
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
          throw UserNotFoundAuthException();
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send password reset email.')),
          );
          throw GenericAuthException();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email.')),
      );
      throw GenericAuthException();
    }
  }
}

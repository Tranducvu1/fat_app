import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/UserModel.dart';
import '../view_auth/login_view.dart';

class UserService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkUserExits(String userId) async {
    try {
      DocumentSnapshot snapshot = await _userCollection.doc(userId).get();
      return snapshot.exists;
    } catch (e) {
      print('Error check user exist: $e');
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    // Hiển thị hộp thoại loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signOut();

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _userCollection.get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      throw e;
    }
  }

  Future<void> updateUser(String userId, UserModel user) async {
    try {
      await _userCollection.doc(userId).update(user.toMap());
      print('Username: ${user.userName}');
      print('Class: ${user.userClass}');
      print('Position: ${user.position}');
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Future<void> route(BuildContext context) async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(user.uid)
  //           .get();

  //       if (documentSnapshot.exists) {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => HomePage(),
  //           ),
  //         );
  //       } else {
  //         print('Document does not exist on the database');
  //       }
  //     } catch (e) {
  //       print('Error fetching document: $e');
  //     }
  //   } else {
  //     print('No user is currently signed in');
  //   }
  // }

  // Future<void> signIn(GlobalKey<FormState> formKey, BuildContext context,
  //     String email, String password) async {
  //   if (formKey.currentState!.validate()) {
  //     try {
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //       Navigator.of(context).pushNamed('/interactlearning');
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'user-not-found') {
  //         print('No user found for that email.');
  //       } else if (e.code == 'wrong-password') {
  //         print('Wrong password provided for that user.');
  //       }
  //     } catch (e) {
  //       print('Error during sign-in: $e');
  //     }
  //   }
  // }

  Future<UserModel> signIn(GlobalKey<FormState> formKey, BuildContext context,
      String email, String password) async {
    if (formKey.currentState!.validate()) {
      try {
        // Sign in with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // Fetch user data from Firestore
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userData.exists) {
          throw Exception("User data not found in database");
        }

        // Convert to UserModel and return
        UserModel user =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);
        print("Fetched user data: $user"); // Debug print
        return user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          throw 'Wrong password provided.';
        } else {
          throw e.message ?? 'Authentication failed';
        }
      } catch (e) {
        throw e.toString();
      }
    } else {
      throw Exception("Form validation failed");
    }
  }

  Future<void> signUp(GlobalKey<FormState> formKey, String username,
      String email, String password, String rool, BuildContext context) async {
    CircularProgressIndicator(); // This line won't show the loader correctly; it should be handled in the UI.

    if (formKey.currentState!.validate()) {
      try {
        // Register user with email and password
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // If registration is successful, save details to Firestore
        await postDetailsToFirestore(email, username, rool, context);
      } catch (e) {
        // Log error if registration fails
        print("Error during sign up: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đăng ký thất bại: $e'),
        ));
      }
    }
  }

  Future<void> postDetailsToFirestore(
      String email, String username, String rool, BuildContext context) async {
    User? user = _auth.currentUser;

    if (user != null) {
      CollectionReference ref = _userCollection;

      try {
        // Save user data to Firestore
        await ref.doc(user.uid).set({
          'username': username,
          'email': email,
          'rool': rool,
        });

        // If successful, navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        // Log error if saving to Firestore fails
        print("Error saving user details: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lưu thông tin người dùng thất bại: $e'),
        ));
      }
    } else {
      print("No user is currently signed in.");
    }
  }
}

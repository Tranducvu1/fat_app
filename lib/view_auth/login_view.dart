import 'package:fat_app/Model/UserModel.dart';

import 'package:fat_app/service/user_service.dart';
import 'package:fat_app/view/Student/MainPage/interact_learning_page.dart';
import 'package:fat_app/view/Teacher/MainPage/Interact_learning_teacher_page.dart';
import 'package:fat_app/view/admin/main_screen.dart';
import 'package:fat_app/view/loading/loading_first_view.dart';
import 'package:fat_app/view/loading/loading_view.dart';
import 'package:fat_app/view_auth/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserService userService = new UserService();
  bool _isObscure3 = true;
  bool visible = false;
  Color customColor = Color(0xC3090808);
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final UserModel usermodel = new UserModel(
      userName: '',
      email: '',
      role: '',
      userClass: '',
      position: '',
      phoneNumber: '',
      createdCourses: [],
      profileImage: '');
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SizedBox(height: 20),
                        Container(
                            margin:
                                EdgeInsets.only(left: 30, top: 40, right: 30),
                            child: Image.asset(
                              'images/img_login.png',
                              fit: BoxFit.cover,
                            )),
                        // SizedBox(height: 20),
                        Text(
                          'WELCOME',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Login in your create account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email, color: customColor),
                            contentPadding: EdgeInsets.all(14.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Email cannot be empty";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock, color: customColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure3
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: customColor,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscure3 = !_isObscure3),
                            ),
                            contentPadding: EdgeInsets.all(14.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("please enter valid password min. 6 character");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),

                        SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                visible = true;
                              });

                              // Assuming you already have the service and the method to sign in
                              userService
                                  .signIn(
                                      _formkey,
                                      context,
                                      emailController.text,
                                      passwordController.text)
                                  .then((user) {
                                setState(() {
                                  visible = false;
                                });

                                print(
                                    "Login successful. User role: ${user.role}");
                                String role = user.role;
                                if (role.isNotEmpty) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => LoadingView(
                                        duration: 3000,
                                        role: role,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Handle invalid role or show an error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Invalid role')));
                                }
                              }).catchError((e) {
                                // Handle login failure (e.g., wrong password, email)
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Login failed: $e')));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child:
                                Text("Login", style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              setState(() => visible = true);
                              // Logic đăng nhập với Google
                              loginWithGoogle(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide(color: Colors.white),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/img_google.png',
                                    width: 24, height: 24),
                                SizedBox(width: 10),
                                Text("Login with Google",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),

                        // Visibility(
                        //     maintainSize: true,
                        //     maintainAnimation: true,
                        //     maintainState: true,
                        //     visible: visible,
                        //     child: Container(
                        //         child: CircularProgressIndicator(
                        //           color: Colors.white,
                        //         ))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              color: Colors.green, // Set background color to green
              width: MediaQuery.of(context).size.width,
              height: 30, // Set the height to match the image's layout
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Not registered yet? ", // Non-clickable text
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Register here", // Clickable text
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // decoration: TextDecoration.underline, // Optional underline effect
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to the Register screen when clicked
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("User canceled the Google sign-in");
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String role = "Student";
      // In ra tên người dùng sau khi đăng nhập thành công
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoadingView(
            duration: 3000,
            role: role,
          ),
        ),
      );
      // Chuyển hướng sang HomePage sau khi đăng nhập thành công
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Đăng nhập thất bại: $e");

      // Có thể thông báo cho người dùng biết về lỗi (sử dụng Snackbar, Toast, v.v.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại: $e")),
      );
    }
  }
}

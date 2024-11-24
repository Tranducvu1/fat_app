import 'package:fat_app/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'login_view.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // State variables for showing progress, visibility toggles, and user information
  bool showProgress = false;
  bool visible = false;
  UserService userService = UserService();

  // Form key to manage form state
  final _formkey = GlobalKey<FormState>();

  // Firebase Authentication instance
  final _auth = FirebaseAuth.instance;

  // Primary color used in UI elements
  Color primaryColor = Color(0xFF4CAF50);

  // Text controllers for form fields
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Booleans for password visibility toggle
  bool _isObscure = true;
  bool _isObscure2 = true;

  // Dropdown options for user roles (Student, Teacher)
  var options = ['Student', 'Teacher'];
  var _currentItemSelected = "Student"; // Default role selected
  var role = "Student"; // Default role value

  @override
  Widget build(BuildContext context) {
    // Building the Register screen
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Center(
        child: SingleChildScrollView(
          // Allow scrolling if content is longer
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formkey, // Connect the form with the form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo at the top
                Image.asset(
                  'images/img_login.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24),

                // Welcome text
                Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),

                // Subheading
                Text(
                  'Create your account to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Username input field
                _buildTextField(
                  controller: username,
                  hintText: 'Username',
                  icon: Icons.account_circle,
                ),
                SizedBox(height: 16),

                // Email input field
                _buildTextField(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password input field
                _buildPasswordField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: _isObscure,
                  onToggle: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Confirm password input field
                _buildPasswordField(
                  controller: confirmpassController,
                  hintText: 'Confirm Password',
                  obscureText: _isObscure2,
                  onToggle: () {
                    setState(() {
                      _isObscure2 = !_isObscure2;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Dropdown for selecting user role (Student or Teacher)
                DropdownButtonFormField<String>(
                  value: _currentItemSelected,
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _currentItemSelected = newValue!;
                      role = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Register button
                ElevatedButton(
                  onPressed: () {
                    // Validate form before registration
                    if (_formkey.currentState!.validate()) {
                      // Call the sign-up method from UserService
                      userService.signUp(
                        _formkey,
                        username.text,
                        emailController.text,
                        passwordController.text,
                        role,
                        context,
                      );
                      Navigator.of(context).pushNamed('/emailverify');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),

                // Navigate to login page if user already has an account
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        // Check if the field is empty
        if (value == null || value.isEmpty) {
          return "$hintText cannot be empty";
        }
        return null;
      },
    );
  }

  // Helper function to build password input fields with visibility toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: primaryColor,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        // Validate password field and ensure passwords match
        if (value == null || value.isEmpty) {
          return "$hintText cannot be empty";
        }
        if (hintText == 'Password' && value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        if (hintText == 'Confirm Password' &&
            value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}

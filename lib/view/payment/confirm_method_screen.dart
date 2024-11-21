import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int type = 1;
  double price = 0.0;
  String subject = '';
  List<String> registeredCourses = [];
  String username = '';
  String creatorId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRegisteredCourses();
    });
  }

  void handleRadio(Object? e) {
    setState(() {
      type = e as int;
    });
  }

  Future<void> _fetchRegisteredCourses() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            registeredCourses =
                List<String>.from(userDoc.data()?['registeredCourses'] ?? []);
          });
        }
      } catch (e) {
        print('Failed to fetch registered courses: $e');
      }
    }
  }

  Future<void> _registerCourse(String courseId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('Users').doc(user.uid).update({
          'registeredCourses': FieldValue.arrayUnion([courseId]),
        });
        if (mounted) {
          _fetchRegisteredCourses();
        }
      } catch (e) {
        print('Failed to register course: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        price = args['price'];
        subject = args['subject'];
        username = args['username'];
        creatorId = args['courseId'];
      });
    }
  }

  Future<void> sendEmail(String subject, String body) async {
    try {
      // Note: Replace with your actual email configuration
      final smtpServer = gmail('your-email@gmail.com', 'your-app-password');
      final message = Message()
        ..from = Address('your-email@gmail.com', 'Payment System')
        ..recipients.add('recipient-email@gmail.com')
        ..subject = subject
        ..text = body;

      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (e) {
      print('Failed to send email: $e');
    }
  }

  Future<void> _updatePaymentStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('Payments').add({
          'userId': user.uid,
          'courseId': subject,
          'amount': price,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print("Payment status updated.");
      } catch (e) {
        print('Failed to update payment status: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Method"),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                RadioListTile(
                  title: const Text("Credit Card"),
                  value: 1,
                  groupValue: type,
                  onChanged: handleRadio,
                ),
                RadioListTile(
                  title: const Text("Bank Transfer"),
                  value: 2,
                  groupValue: type,
                  onChanged: handleRadio,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Payment Successful'),
                            content:
                                Text('You have paid \$$price for $subject'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _updatePaymentStatus();
                                  _registerCourse(creatorId);
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .pushReplacementNamed('/courses');
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                      await sendEmail("Payment Notification",
                          "$username đã thanh toán \$$price cho khóa học: $subject");
                    } catch (e) {
                      print('Error during payment process: $e');
                      // Consider showing an error dialog to the user
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                  ),
                  child: const Text("Pay"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

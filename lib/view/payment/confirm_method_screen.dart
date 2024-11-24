import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String _creatorEmail = '';
  late final SmtpServer _gmailSmtp;

  int _selectedPaymentType = 1;
  double _price = 0.0;
  String _subject = '';
  String _username = '';
  String _creatorId = '';

  final Map<int, String> _paymentMethods = {
    1: 'Amazon Pay',
    2: 'PayPal',
    3: 'Google Pay',
    4: 'Visa',
    5: 'MasterCard',
  };

  final Map<int, String> _paymentMethodImages = {
    1: 'images/bank/amazon.png',
    2: 'images/bank/paypal.png',
    3: 'images/bank/google.png',
    4: 'images/bank/visa.png',
    5: 'images/bank/master card.png'
  };

  @override
  void initState() {
    super.initState();
    _initializeSmtpServer();
  }

  void _initializeSmtpServer() {
    final gmailUser = dotenv.env["GMAIL_MAIL"];
    final gmailPassword = dotenv.env["GMAIL_PASSWORD"];

    if (gmailUser == null || gmailPassword == null) {
      throw Exception('Gmail credentials not found in environment variables');
    }

    _gmailSmtp = gmail(gmailUser, gmailPassword);
  }

  Future<void> sendEmail(String subject, String content) async {
    try {
      final userEmail = _auth.currentUser?.email;
      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found');
      }

      final emailTemplate = '''
Dear $_username,

Thank you for purchasing the course "$_subject". Here are your purchase details:

Course: $_subject
Amount Paid: \$$_price
Date: ${DateTime.now().toString().split('.')[0]}

You can now access your course through the learning platform. We hope you enjoy learning with us!

If you have any questions or need assistance, please don't hesitate to contact our support team.

Best regards,
The Learning Fat Team''';

      final message = Message()
        ..from = Address(dotenv.env["GMAIL_MAIL"] ?? '', 'Fat Information')
        ..recipients.add(userEmail)
        ..subject = 'Course Purchase Confirmation - $_subject'
        ..text = emailTemplate;

      await send(message, _gmailSmtp);
    } catch (e) {
      debugPrint('Error sending student email: $e');
      throw Exception('Failed to send confirmation email: ${e.toString()}');
    }
  }

  Future<void> sendEmailByCreator(String subject, String content) async {
    try {
      if (_creatorEmail.isEmpty) {
        throw Exception('Creator email not found');
      }

      final emailTemplate = '''
Dear Course Creator,

Great news! Your course "$_subject" has a new student.

Purchase Details:
- Student Name: $_username
- Course: $_subject
- Revenue: \$$_price
- Purchase Date: ${DateTime.now().toString().split('.')[0]}

The student can now access your course content. Please ensure all materials are up to date.

Thank you for being part of our learning community!

Best regards,
The Learning Fat Team''';

      final message = Message()
        ..from = Address(dotenv.env["GMAIL_MAIL"] ?? '', 'Fat Information')
        ..recipients.add(_creatorEmail)
        ..subject = 'New Student Enrollment - $_subject'
        ..text = emailTemplate;

      await send(message, _gmailSmtp);
    } catch (e) {
      debugPrint('Error sending creator email: $e');
      throw Exception('Failed to send creator notification: ${e.toString()}');
    }
  }

  Future<void> _updatePaymentStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('Payments').add({
        'userId': user.uid,
        'courseId': _subject,
        'amount': _price,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to update payment status: $e');
      rethrow;
    }
  }

  Future<void> _registerCourse() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('Users').doc(user.uid).update({
        'registeredCourses': FieldValue.arrayUnion([_creatorId]),
      });
    } catch (e) {
      debugPrint('Failed to register course: $e');
      rethrow;
    }
  }

  Future<void> _processPayment() async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('You have paid \$$_price for $_subject'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Perform operations in order
                  await _updatePaymentStatus();
                  await _registerCourse();

                  // Send emails
                  await Future.wait([
                    sendEmail(
                      "Course Purchase Confirmation - $_subject",
                      "", // Content is defined in the method
                    ),
                    sendEmailByCreator(
                      "New Student Enrollment - $_subject",
                      "", // Content is defined in the method
                    ),
                  ]).catchError((error) {
                    debugPrint('Error sending emails: $error');
                    // Continue processing even if emails fail
                  });

                  // Close loading indicator
                  if (mounted) {
                    Navigator.of(context).pop();
                  }

                  // Navigate to course page
                  if (mounted) {
                    Navigator.of(context).pop(); // Close success dialog
                    Navigator.of(context).pushReplacementNamed('/course');
                  }
                } catch (e) {
                  // Close loading indicator if error occurs
                  if (mounted) {
                    Navigator.of(context).pop();
                  }

                  debugPrint('Error during payment process: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Payment processing failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error showing payment dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
        _price = args['price'] ?? 0.0;
        _subject = args['subject'] ?? '';
        _username = args['username'] ?? '';
        _creatorId = args['courseId'] ?? '';
        _creatorEmail = args['email'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Email received: $_creatorEmail');
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Select Payment Method",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  children: _paymentMethods.entries.map((entry) {
                    return RadioListTile<int>(
                      title: Row(
                        children: [
                          Image.asset(
                            _paymentMethodImages[entry.key] ?? '',
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                          const SizedBox(width: 10),
                          Text(entry.value),
                        ],
                      ),
                      value: entry.key,
                      groupValue: _selectedPaymentType,
                      onChanged: (value) =>
                          setState(() => _selectedPaymentType = value!),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                  ),
                  child: const Text("Pay"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

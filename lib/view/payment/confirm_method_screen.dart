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
  String username = '';

  void handleRadio(Object? e) {
    setState(() {
      type = e as int;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    price = args['price'];
    subject = args['subject'];
    username = args['username'];
  }

  Future<void> sendEmail(String subject, String body) async {
    final smtpServer = gmail('tranducvuht@gmail.com',
        '0345934782'); // Thay thế bằng email và mật khẩu ứng dụng của bạn

    final message = Message()
      ..from = Address('tranducvuht@gmail.com', 'Payment System')
      ..recipients.add('tranducvuht@gmail.com')
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (e) {
      print('Failed to send email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Method"),
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Text(
                    "Select Payment Method",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                RadioListTile(
                  title: Text("Credit Card"),
                  value: 1,
                  groupValue: type,
                  onChanged: handleRadio,
                ),
                RadioListTile(
                  title: Text("Bank Transfer"),
                  value: 2,
                  groupValue: type,
                  onChanged: handleRadio,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Handle payment logic here
                    // Call your payment processing function

                    // Simulate successful payment
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Payment Successful'),
                          content: Text('You have paid \$$price for $subject'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Update user's payment status in Firestore
                                _updatePaymentStatus();
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );

                    // Send email notification
                    sendEmail("Payment Notification",
                        "$username đã thanh toán \$$price cho khóa học: $subject");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 80),
                  ),
                  child: Text("Pay"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updatePaymentStatus() async {
    User? user = _auth.currentUser; // Lấy người dùng hiện tại
    if (user != null) {
      try {
        await _firestore.collection('Users').doc(user.uid).update({
          'hasPaid': true,
        });
      } catch (e) {
        print('Failed to update payment status: $e');
      }
    }
  }
}

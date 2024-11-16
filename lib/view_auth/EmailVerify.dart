import 'package:fat_app/auth/auth_service.dart';
import 'package:fat_app/constants/routes.dart';
import 'package:flutter/material.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({Key? key}) : super(key: key);

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification. Please open it to verify your account."),
          const Text(
              "If you haven't received a verification email yet, press the button below"),
          TextButton(
            onPressed: () async {
              try {
                await AuthServices.firebase(context).sendEmailVertification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error sending verification email: $e')),
                );
              }
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AuthServices.firebase(context).LogOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoutes,
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error logging out: $e')),
                );
              }
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

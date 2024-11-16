import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
          ),
          Container(
            height: 300,
            width: 400,
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Lottie.network(
                'https://lottie.host/af563ef5-b41f-41e7-b75a-9a8435d81d1e/MlTrZzPVnC.json'),
          ),
          SizedBox(height: 20),
          Text(
            "Track Progress",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Track your learning progress and receive feedback from your tutor to improve your learning outcomes.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

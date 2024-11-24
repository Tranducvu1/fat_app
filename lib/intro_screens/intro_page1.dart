import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[700],
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 80,
          ),
          const Center(
            child: Text(
              "FIND TUTOR",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 300,
            width: 400,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: Lottie.network(
                'https://lottie.host/6c6f9e0c-a63c-4749-a320-94267e0c5cbb/A1cN2JEgOm.json'),
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Explore and connect with professional tutors to support your learning journey.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )),
        ],
      ),
    );
  }
}

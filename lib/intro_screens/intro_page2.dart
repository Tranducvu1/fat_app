import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

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
                'https://lottie.host/f256f1de-2aa1-4b36-aee4-163792eb0633/ENLbIUY25Z.json'),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Learn Anytime, Anywhere",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Learn online easily with diverse courses, suitable for your needs.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

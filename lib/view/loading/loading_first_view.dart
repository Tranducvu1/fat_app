import 'package:flutter/material.dart';

class LoadingViewFirst extends StatelessWidget {
  const LoadingViewFirst({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

import 'package:fat_app/constants/constant_routes.dart';
import 'package:flutter/material.dart';

class LoadingTeacherView extends StatefulWidget {
  final int duration;
  const LoadingTeacherView({Key? key, required this.duration})
      : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingTeacherView> {
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    for (int i = 0; i <= 50; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      setState(() {
        _progress = i;
      });
    }

    Navigator.of(context).pushNamed('/interactlearning');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.greenAccent,
              backgroundColor: Colors.blueGrey,
            ),
            SizedBox(height: 20),
            //     Text('$_progress%'),
          ],
        ),
      ),
    );
  }
}

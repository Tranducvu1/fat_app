import 'package:fat_app/view/Student/MainPage/interact_learning_page.dart';
import 'package:fat_app/view/Teacher/MainPage/Interact_learning_teacher_page.dart';
import 'package:fat_app/view/admin/main_screen.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  final int duration;
  final String role;
  const LoadingView({Key? key, required this.duration, required this.role})
      : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
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

    if (widget.role == 'Student') {
      Navigator.of(context).pushReplacementNamed('/interactlearning');
    } else if (widget.role == 'Admin') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else if (widget.role == 'Teacher') {
      Navigator.of(context).pushReplacementNamed('/teacherinteractlearning');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
          ],
        ),
      ),
    );
  }
}

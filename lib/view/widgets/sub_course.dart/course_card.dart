import 'package:flutter/material.dart';
import 'package:fat_app/Model/Courses.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isRegistered;
  final VoidCallback onTap;

  const CourseCard({
    Key? key,
    required this.course,
    required this.isRegistered,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              course.subject,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              course.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              isRegistered ? 'Registered' : 'Register',
              style: TextStyle(
                color: isRegistered ? Colors.green : Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

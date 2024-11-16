import 'package:flutter/material.dart';

class SubjectChipsWidget extends StatelessWidget {
  final List<String> subjects;

  const SubjectChipsWidget(
      {Key? key, required this.subjects, String? selectedSubject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: subjects.map((subject) {
        return Chip(
          label: Text(subject),
          backgroundColor: Colors.blue.shade100,
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';

class SubjectChipsWidget extends StatelessWidget {
  final List<String> subjects;
  // Constructor to initialize the list of subjects and optionally a selected subject
  const SubjectChipsWidget(
      {Key? key, required this.subjects, String? selectedSubject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Space between chips
      children: subjects.map((subject) {
        // Map each subject to a Chip widget
        return Chip(
          label: Text(subject),
          backgroundColor: Colors.blue.shade100,
        );
      }).toList(),
    );
  }
}

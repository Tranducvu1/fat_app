import 'package:flutter/material.dart';

Future<void> Show_Error_Dialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('No Lectures Available'),
      content: const Text('No lectures have been added to this course yet.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

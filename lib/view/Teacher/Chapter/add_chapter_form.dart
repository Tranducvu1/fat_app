import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/service/courses_service.dart';
import 'package:flutter/material.dart';

import 'package:fat_app/service/chapter_service.dart';

class AddChapterForm extends StatefulWidget {
  final Function() onChapterAdded;
  final String courseId;

  const AddChapterForm({
    Key? key,
    required this.onChapterAdded,
    required this.courseId,
  }) : super(key: key);

  @override
  _AddChapterFormState createState() => _AddChapterFormState();
}

class _AddChapterFormState extends State<AddChapterForm> {
  final _formKey = GlobalKey<FormState>();
  final ChapterService _chapterService = ChapterService();
  final CourseService _courseService = CourseService();

  late TextEditingController _chapterIdController;
  late TextEditingController _chapterNameController;

  @override
  void initState() {
    super.initState();
    _chapterIdController = TextEditingController();
    _chapterNameController = TextEditingController();

    print('Function onChapterAdded: ${widget.onChapterAdded}');
    print('Course ID: ${widget.courseId}');
  }

  @override
  void dispose() {
    _chapterIdController.dispose();
    _chapterNameController.dispose();
    super.dispose();
  }

  Future<void> _submitChapter() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Store the chapterId as a string, then convert to int for the model
        final String chapterIdStr = _chapterIdController.text;
        final int chapterId = int.parse(chapterIdStr); // Convert to int safely
        final chapter = Chapter(
          chapterId:
              int.parse(chapterIdStr), // Ensure conversion to int is valid
          chapterName: _chapterNameController.text,
          lessonId: [],
        );

        // Add the chapter to the database
        await _chapterService.addChapter(chapter);
        print('Chapter ID: $chapter');

        // Update the course's chapterIds array with the chapterId as a string
        await _courseService.addChapterToCourse(widget.courseId, chapterId);
        print('Course ID: ${widget.courseId}');
        print('Chapter ID: $chapterId');
        // Notify that a new chapter was added
        widget.onChapterAdded();

        // Clear the form and show a success message
        _chapterIdController.clear();
        _chapterNameController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chapter added successfully')),
          );
          Navigator.pop(context); // Close the form
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding chapter: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Chapter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _chapterIdController,
                decoration: const InputDecoration(
                  labelText: 'Chapter ID',
                  hintText: 'Enter chapter number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chapter ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chapterNameController,
                decoration: const InputDecoration(
                  labelText: 'Chapter Name',
                  hintText: 'Enter chapter name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chapter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitChapter,
                child: const Text('Add Chapter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

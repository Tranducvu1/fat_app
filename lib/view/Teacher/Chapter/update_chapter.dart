import 'package:fat_app/Model/chapter.dart'; // Import the Chapter model for data structure
import 'package:fat_app/service/courses_service.dart'; // Import course service for course management
import 'package:fat_app/service/chapter_service.dart'; // Import chapter service for chapter management
import 'package:flutter/material.dart'; // Flutter material design package for UI components

class UpdateChapterForm extends StatefulWidget {
  // The form expects three parameters: onChapterUpdated (callback), courseId (string), and chapter (the Chapter to update)
  final Function()
      onChapterUpdated; // Callback function to trigger UI updates after chapter is updated
  final String courseId; // Course ID to associate the chapter with
  final Chapter chapter; // The chapter to be updated

  const UpdateChapterForm({
    Key? key,
    required this.onChapterUpdated, // Ensures this function is passed when creating the widget
    required this.courseId,
    required this.chapter,
  }) : super(key: key); // Constructor for the StatefulWidget class

  @override
  _UpdateChapterFormState createState() => _UpdateChapterFormState();
}

class _UpdateChapterFormState extends State<UpdateChapterForm> {
  final _formKey = GlobalKey<FormState>(); // Form key for validating the form
  final ChapterService _chapterService =
      ChapterService(); // Service to handle chapter updates
  final CourseService _courseService =
      CourseService(); // Service to handle adding chapters to courses

  // Controllers for text input fields
  late TextEditingController _chapterIdController;
  late TextEditingController _chapterNameController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing chapter data
    _chapterIdController =
        TextEditingController(text: widget.chapter.chapterId.toString());
    _chapterNameController =
        TextEditingController(text: widget.chapter.chapterName);

    print(
        'Function onChapterUpdated: ${widget.onChapterUpdated}'); // Debugging info
    print('Course ID: ${widget.courseId}');
  }

  @override
  void dispose() {
    // Dispose the controllers to release memory when the form is removed
    _chapterIdController.dispose();
    _chapterNameController.dispose();
    super.dispose();
  }

  // Method to handle the submission of the update
  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      // Check if the form inputs are valid
      try {
        // Get the chapterId and chapterName from the form controllers
        final String chapterIdStr = _chapterIdController.text;
        final int chapterId = int.parse(chapterIdStr); // Convert to integer

        // Create an updated Chapter object with new values
        final updatedChapter = Chapter(
          chapterId: chapterId,
          chapterName: _chapterNameController.text,
          lessonId: widget.chapter.lessonId, // Keep the lessonId unchanged
        );

        // Update the chapter in the database
        await _chapterService.updateChapter(updatedChapter);
        print('Updated Chapter: $updatedChapter');

        // Add the updated chapter to the course
        await _courseService.addChapterToCourse(widget.courseId, chapterId);
        print('Course ID: ${widget.courseId}');
        print('Chapter ID: $chapterId');

        // Trigger the callback function to update the parent widget
        widget.onChapterUpdated();

        // Clear the form fields after successful update
        _chapterIdController.clear();
        _chapterNameController.clear();

        // Show success message and close the form
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chapter updated successfully')),
          );
          Navigator.pop(context); // Close the form screen
        }
      } catch (e) {
        // Show an error message in case of failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating chapter: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Chapter'), // App bar with title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for form fields
        child: Form(
          key: _formKey, // Associate the form with the formKey for validation
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align the form fields vertically
            children: [
              // Chapter ID input field with validation
              TextFormField(
                controller: _chapterIdController,
                decoration: const InputDecoration(
                  labelText: 'Chapter ID',
                  hintText: 'Enter chapter number',
                ),
                keyboardType:
                    TextInputType.number, // Numeric keyboard for ID input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chapter ID'; // Validation for empty field
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number'; // Validation for non-numeric input
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Space between fields
              // Chapter name input field with validation
              TextFormField(
                controller: _chapterNameController,
                decoration: const InputDecoration(
                  labelText: 'Chapter Name',
                  hintText: 'Enter chapter name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chapter name'; // Validation for empty field
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), // Space between fields
              // Submit button
              ElevatedButton(
                onPressed:
                    _submitUpdate, // Call the _submitUpdate function on press
                child: const Text('Update Chapter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

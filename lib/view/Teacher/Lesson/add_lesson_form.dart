import 'package:flutter/material.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/service/chapter_service.dart';

class AddLessonForm extends StatefulWidget {
  final int chapterId;
  final Function() onLessonAdded;

  const AddLessonForm({
    Key? key,
    required this.chapterId,
    required this.onLessonAdded,
  }) : super(key: key);

  @override
  _AddLessonFormState createState() => _AddLessonFormState();
}

class _AddLessonFormState extends State<AddLessonForm> {
  final _formKey = GlobalKey<FormState>();
  final ChapterService _chapterService = ChapterService();

  late TextEditingController _lessonIdController;
  late TextEditingController _lessonNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoController;

  @override
  void initState() {
    super.initState();
    _lessonIdController = TextEditingController();
    _lessonNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _videoController = TextEditingController();
  }

  @override
  void dispose() {
    _lessonIdController.dispose();
    _lessonNameController.dispose();
    _descriptionController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  // Function to extract YouTube video ID
  String? extractYouTubeVideoId(String url) {
    final regex = RegExp(
        r"^(?:https?:\/\/)?(?:www\.)?(?:youtube|youtu|youtube-nocookie)\.(?:com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|(?:youtube\.com\/(?:v|e(?:mbed)?\/)?)|(?:youtu\.be\/))([\w-]{11})");
    final match = regex.firstMatch(url);
    return match?.group(1); // Returns the video ID if a match is found
  }

  Future<void> _submitLesson() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Extract YouTube video ID if the URL is provided
        String videoUrl = _videoController.text;
        String? videoId = extractYouTubeVideoId(videoUrl);

        if (videoId != null) {
          videoUrl = videoId; // Use the video ID if extracted
        }

        final lesson = Lesson(
          lesson_ID: int.parse(_lessonIdController.text),
          lessonName: _lessonNameController.text,
          description: _descriptionController.text,
          video: videoUrl, // Store the video ID instead of full URL
          createdAt: DateTime.now().toIso8601String(), questionid: [],
        );

        // Add lesson to Firestore
        await _chapterService.addLesson(lesson);

        // Add the lesson ID to the chapter's lesson_ID array
        await _chapterService.addLessonIdToChapter(
            widget.chapterId, lesson.lesson_ID);

        widget.onLessonAdded();

        // Clear form and show success message
        _lessonIdController.clear();
        _lessonNameController.clear();
        _descriptionController.clear();
        _videoController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lesson added successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding lesson: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Lesson'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _lessonIdController,
                decoration: const InputDecoration(
                  labelText: 'Lesson ID',
                  hintText: 'Enter lesson number',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lesson ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lessonNameController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Name',
                  hintText: 'Enter lesson name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lesson name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter lesson description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lesson description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  hintText: 'Enter video URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter video URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitLesson,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

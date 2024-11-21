import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/service/chapter_service.dart';
import 'package:fat_app/view/Student/Chapter/question_page.dart';
import 'package:fat_app/view/Teacher/Chapter/add_chapter_form.dart';
import 'package:fat_app/view/Teacher/Chatroom/teacher_screen.dart';
import 'package:fat_app/view/Teacher/Lesson/add_lesson_form.dart';
import 'package:fat_app/view/Teacher/question/add_question_page.dart';

import 'package:flutter/material.dart';
import 'package:fat_app/view/live/live.dart';

class LectureListTeacherScreen extends StatefulWidget {
  final List<int>? chapterId;
  final Course course;

  const LectureListTeacherScreen({
    Key? key,
    this.chapterId,
    required this.course,
  }) : super(key: key);

  @override
  _LectureListTeacherScreenState createState() =>
      _LectureListTeacherScreenState();
}

class _LectureListTeacherScreenState extends State<LectureListTeacherScreen> {
  final ChapterService _chapterService = ChapterService();
  List<Chapter> chapters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildChapterList(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.course.subject),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddChapterForm(context),
          tooltip: 'Add Chapter',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => jumToLivePage(context, isHost: true),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Starting live'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Implement notifications
          },
        ),
      ],
    );
  }

  void _showAddChapterForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddChapterForm(
          onChapterAdded: _handleNewChapter,
          courseId: widget.course.creatorId,
        ),
      ),
    );
  }

  void _handleNewChapter() {
    setState(() {});
  }

  Widget _buildChapterList(BuildContext context) {
    if (widget.chapterId == null || widget.chapterId!.isEmpty) {
      return _buildEmptyState(context);
    }

    return StreamBuilder<List<Chapter>>(
      stream: _chapterService.getChaptersForCourse(widget.chapterId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chapters = snapshot.data ?? [];

        if (chapters.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            return ChapterTile(
              chapter: chapters[index],
              chapterService: _chapterService,
              course: widget.course,
              lessonId: widget.chapterId!,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No chapters available'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddChapterForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Chapter'),
          ),
        ],
      ),
    );
  }

  void jumToLivePage(BuildContext context, {required bool isHost}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LivePage(isHost: isHost),
      ),
    );
  }
}

class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterService chapterService;
  final Course course;
  final List<int> lessonId;

  const ChapterTile({
    Key? key,
    required this.chapter,
    required this.chapterService,
    required this.course,
    required this.lessonId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: Text(
            "Chapter ${chapter.chapterId}: ${chapter.chapterName}",
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          children: [
            _buildLessonList(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddLessonForm(
                            chapterId: chapter.chapterId,
                            onLessonAdded: () {},
                          ),
                        ),
                      );
                    },
                    tooltip: 'Add Lesson',
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLessonList() {
    return StreamBuilder<List<Lesson>>(
      stream: chapterService.getLessonsForChapters(
        chapter.lessonId.map(int.parse).toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ListTile(title: Text('Error loading lessons'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const ListTile(title: Text('No lessons available'));
        }

        return Column(
          children: snapshot.data!
              .map((lesson) => LessonTile(lesson: lesson))
              .toList(),
        );
      },
    );
  }
}

class LessonTile extends StatelessWidget {
  final Lesson lesson;

  const LessonTile({
    Key? key,
    required this.lesson,
  }) : super(key: key);

  Stream<int> getQuestionCount() {
    return FirebaseFirestore.instance
        .collection('questions')
        .where('lessonId', isEqualTo: lesson.lesson_ID)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      title: Text(
        lesson.lessonName,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        lesson.description,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.video_library_outlined, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      TeacherScreen(lessonId: lesson.lesson_ID),
                ),
              );
            },
          ),
          StreamBuilder<int>(
            stream: getQuestionCount(),
            builder: (context, snapshot) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.quiz_outlined, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Quiz Options'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.add_circle_outline),
                                title: const Text('Add Questions'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddQuestionPage(
                                        lessonId: lesson.lesson_ID.toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.play_arrow),
                                title: const Text('Start Quiz'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuestionPage(
                                        lessonId: lesson.questionid,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (snapshot.hasData && snapshot.data! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${snapshot.data}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/service/chapter_service.dart';
import 'package:fat_app/view/Student/Chapter/question_page.dart';
import 'package:fat_app/view/Teacher/Chatroom/teacher_screen.dart';
import 'package:fat_app/view/live/live.dart';
import 'package:flutter/material.dart';

class LectureListScreen extends StatelessWidget {
  final ChapterService _chapterService = ChapterService();
  final List<int>? chapterId;
  final Course course;

  LectureListScreen({
    Key? key,
    this.chapterId,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Received chapterId: $chapterId");
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
      title: Text(course.subject),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              jumToLivePage(context, isHost: true);
            },
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
            // TODO: Implement notifications
          },
        ),
      ],
    );
  }

  Widget _buildChapterList(BuildContext context) {
    if (chapterId == null || chapterId!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No chapters available'),
          ],
        ),
      );
    }

    return StreamBuilder<List<Chapter>>(
      stream: _chapterService.getChaptersForCourse(chapterId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}', // Hiển thị thông báo lỗi chi tiết
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No chapters available'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Chapter'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return ChapterTile(
              chapter: snapshot.data![index],
              chapterService: _chapterService,
              course: course,
              lessonId: chapterId!,
            );
          },
        );
      },
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
    print("Chapter ${chapter.chapterId} has lesson_IDs: ${chapter.lessonId}");
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
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLessonList() {
    print(' lesson id :${chapter.lessonId.map(int.parse).toList()}');
    return StreamBuilder<List<Lesson>>(
      stream: chapterService
          .getLessonsForChapters(chapter.lessonId.map(int.parse).toList()),
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
    print('Thông tin lesson_ID: ${lesson.questionid}');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      title: Text(
        "${lesson.lessonName}",
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
          // Wrapped Quiz button with StreamBuilder to show question count
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
                          title: Text('Quiz Options'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.play_arrow),
                                title: Text('Start Quiz'),
                                onTap: () {
                                  print('trỏ tới :${lesson.lesson_ID}');
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

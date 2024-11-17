// lib/Model/lesson.dart
class Lesson {
  final int lesson_ID;
  final String description;
  final String lessonName;
  final String video;
  final String? createdAt;
  final List<String> questionid;

  Lesson(
      {required this.lesson_ID,
      required this.description,
      required this.lessonName,
      required this.video,
      this.createdAt,
      required this.questionid});

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      lesson_ID: map['lesson_ID'] ?? 0,
      description: map['description'] ?? '',
      lessonName: map['lessonName'] ?? '',
      video: map['video'] ?? '',
      createdAt: map['createdAt'],
      questionid: List<String>.from(map['Question_ID'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lesson_ID': lesson_ID,
      'description': description,
      'lessonName': lessonName,
      'video': video,
      'createdAt': createdAt,
      'Question_ID': questionid
    };
  }
}

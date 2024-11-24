class Chapter {
  final int chapterId;
  final String chapterName;
  final List<String> lessonId;

  const Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.lessonId,
  });

  // Convert Firestore document data into Chapter object
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapterId: map['chapterId'] ?? 0,
      chapterName: map['chapterName'] ?? '',
      lessonId: List<String>.from(
          map['lesson_ID'] ?? []), // Convert dynamic to List<String>
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'lesson_ID': lessonId,
    };
  }

// Compare this snippet from lib/Model/lesson.dart:
  @override
  String toString() {
    return 'Chapter(chapterId: $chapterId, chapterName: $chapterName, lessonId: $lessonId)';
  }
}

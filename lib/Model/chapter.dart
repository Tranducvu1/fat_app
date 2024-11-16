class Chapter {
  final int chapterId;
  final String chapterName;
  final List<String> lessonId;

  const Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.lessonId,
  });

  // Tạo đối tượng Chapter từ map (dữ liệu Firestore)
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      chapterId: map['chapterId'] ?? 0,
      chapterName: map['chapterName'] ?? '',
      lessonId: List<String>.from(
          map['lesson_ID'] ?? []), // Đảm bảo Lesson là danh sách
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapterId': chapterId,
      'chapterName': chapterName,
      'lesson_ID': lessonId,
    };
  }

  @override
  String toString() {
    return 'Chapter(chapterId: $chapterId, chapterName: $chapterName, lessonId: $lessonId)';
  }
}

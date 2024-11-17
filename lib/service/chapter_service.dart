import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/Model/question.dart';

class ChapterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Chapter>> getChapters() {
    return _firestore
        .collection('chapter')
        .orderBy('chapterId') // Added ordering
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chapter.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addLesson(Lesson lesson) async {
    try {
      // Add lesson document to Firestore
      await _firestore.collection('lesson').add(lesson.toMap());
      print('Lesson added successfully!');
    } catch (e) {
      print('Failed to add lesson: $e');
      throw Exception('Failed to add lesson: $e');
    }
  }

  Stream<List<Chapter>> getChaptersForCourse(List<int> chapterIds) {
    print('Fetching chapters for course: $chapterIds');
    return _firestore
        .collection('chapter')
        .where('chapterId', whereIn: chapterIds)
        .orderBy('chapterId')
        .snapshots()
        .map((snapshot) {
      print('Received snapshot with ${snapshot.docs.length} docs');
      return snapshot.docs.map((doc) {
        var data = doc.data();
        print('Document data: $data');
        return Chapter.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  Stream<List<Question>> getQuestionorLesson(List<int> chapterIds) {
    print('Fetching chapters for course: $chapterIds');
    return _firestore
        .collection('questions')
        .where('id', whereIn: chapterIds)
        .orderBy('id')
        .snapshots()
        .map((snapshot) {
      print('Received snapshot with ${snapshot.docs.length} docs');
      return snapshot.docs.map((doc) {
        var data = doc.data();
        print('Document data: $data');
        return Question.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  Stream<List<Lesson>> getLessonsForChapters(List<int> lessonIds) {
    print('Fetching lessons for chapters: $lessonIds');

    if (lessonIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('lesson')
        .where('lesson_ID', whereIn: lessonIds)
        .orderBy('lesson_ID')
        .snapshots()
        .map((snapshot) {
      print('Received snapshot with ${snapshot.docs.length} docs');
      return snapshot.docs.map((doc) {
        var data = doc.data();
        print('Document data: $data');
        return Lesson.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addChapter(Chapter chapter) =>
      _firestore.collection('chapter').add(chapter.toMap());

  // Add lesson to chapter's lesson_ID array
  Future<void> addLessonIdToChapter(int chapterId, int lessonId) async {
    try {
      // Get the chapter document reference
      var chapterRef = _firestore
          .collection('chapter')
          .where('chapterId', isEqualTo: chapterId);
      var snapshot = await chapterRef.get();

      if (snapshot.docs.isEmpty) {
        throw Exception("No chapter found with chapterId: $chapterId");
      }

      // Assuming only one chapter document is found
      var chapterDoc = snapshot.docs.first;

      // Update the lesson_ID array field of the chapter document
      await chapterDoc.reference.update({
        'lesson_ID': FieldValue.arrayUnion([lessonId.toString()])
      });

      print('Lesson ID added to chapter successfully!');
    } catch (e) {
      print('Failed to update chapter: $e');
      throw Exception('Failed to update chapter: $e');
    }
  }

  Future<void> updateChapter(String docId, Chapter chapter) =>
      _firestore.collection('chapter').doc(docId).update(chapter.toMap());

  Future<void> updateLesson(String docId, Lesson lesson) =>
      _firestore.collection('lesson').doc(docId).update(lesson.toMap());

  Future<void> deleteChapter(String docId) =>
      _firestore.collection('chapter').doc(docId).delete();

  Future<void> deleteLesson(String docId) =>
      _firestore.collection('lesson').doc(docId).delete();
}

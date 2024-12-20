import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/Model/question.dart';

class ChapterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//get all chapters
  Stream<List<Chapter>> getChapters() {
    return _firestore
        .collection('chapter')
        .orderBy('chapterId') // Added ordering
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chapter.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  //get lessons
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

  //get chapters for course by chapterId
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

  //get questions for lesson
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

  //get lessons for chapters
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

  //add chapter
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

  Future<void> updateChapter(Chapter chapter) async {
    try {
      await _firestore
          .collection('chapters')
          .doc(chapter.chapterId.toString())
          .update({
        'chapterName': chapter.chapterName,
        'lessonId': chapter.lessonId,
      });
    } catch (e) {
      throw Exception('Failed to update chapter: $e');
    }
  }

  Future<void> deleteChapter(String docId) =>
      _firestore.collection('chapter').doc(docId).delete();
}

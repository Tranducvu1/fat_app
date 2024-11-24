import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/lesson.dart';

import '../constants/basefires_constant.dart';

class LessonService extends BaseFirestoreService {
  static const String _collection = 'lesson';

  LessonService({super.firestore});

  Future<Lesson> getLessonByLessonId(int lessonId) async {
    return handleError(() async {
      final QuerySnapshot querySnapshot = await firestore
          .collection(_collection)
          .where('lesson_ID', isEqualTo: lessonId)
          .limit(1) // Optimization: limit to 1 since we only need one
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Lesson not found with ID: $lessonId');
      }

      final doc = querySnapshot.docs.first;
      print('Found lesson - ID: ${doc['lesson_ID']}, Doc ID: ${doc.id}');

      return Lesson.fromMap(doc.data() as Map<String, dynamic>);
    }, 'get lesson');
  }

  Future<void> updateLesson(Lesson lesson) async {
    return handleError(() async {
      await firestore
          .collection(_collection)
          .doc(lesson.lesson_ID.toString())
          .update(lesson.toMap());
    }, 'update lesson');
  }
}

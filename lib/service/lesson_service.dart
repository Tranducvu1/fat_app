// lib/service/lesson_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/lesson.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Lesson> getLessonByLessonId(int lessonId) async {
    try {
      // Truy vấn Firestore để tìm tài liệu có trường `lesson_ID` bằng `lessonId`
      final QuerySnapshot querySnapshot = await _firestore
          .collection('lesson')
          .where('lesson_ID', isEqualTo: lessonId)
          .get();

      // Kiểm tra xem có kết quả nào được trả về hay không
      if (querySnapshot.docs.isNotEmpty) {
        // Lấy tài liệu đầu tiên từ kết quả truy vấn
        final DocumentSnapshot doc = querySnapshot.docs.first;
        print('Lesson ID: ${doc['lesson_ID']}');
        print('Document ID: ${doc.id}');

        // Trả về đối tượng `Lesson`
        return Lesson.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Lesson not found');
      }
    } catch (e) {
      throw Exception('Failed to load lesson: $e');
    }
  }

  // Add a new lesson
  Future<void> addLesson(Lesson lesson) async {
    try {
      await _firestore
          .collection('lesson')
          .doc(lesson.lesson_ID.toString())
          .set(lesson.toMap());
    } catch (e) {
      throw Exception('Failed to add lesson: $e');
    }
  }

  //Update an existing lesson
  Future<void> updateLesson(Lesson lesson) async {
    try {
      await _firestore
          .collection('lesson')
          .doc(lesson.lesson_ID.toString())
          .update(lesson.toMap());
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

//
  // Delete a lesson
  Future<void> deleteLesson(int lessonId) async {
    try {
      await _firestore.collection('lesson').doc(lessonId.toString()).delete();
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }
}

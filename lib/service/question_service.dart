// services/quiz_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/Model/question.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String questionCollection = 'questions';
  late final Lesson lessonTile;
  Future<void> addQuestion(Question question) async {
    try {
      await _firestore
          .collection(questionCollection)
          .doc(question.id)
          .set(question.toMap());
    } catch (e) {
      print('Error adding question: $e');
      rethrow;
    }
  }

  Future<void> updateQuestion(Question question) async {
    try {
      await _firestore
          .collection(questionCollection)
          .doc(question.id)
          .update(question.toMap());
    } catch (e) {
      print('Error updating question: $e');
      rethrow;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _firestore
          .collection(questionCollection)
          .doc(questionId)
          .update({'isActive': false});
    } catch (e) {
      print('Error deleting question: $e');
      rethrow;
    }
  }

  Future<List<Question>> getQuestions() async {
    try {
      final querySnapshot = await _firestore
          .collection(questionCollection)
          .where('lessonId', isEqualTo: lessonTile.lesson_ID)
          .where('isActive', isEqualTo: true)
          .where('createdBy', isEqualTo: lessonTile.createdAt)
          .get();

      return querySnapshot.docs
          .map((doc) => Question.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      print('Error getting questions: $e');
      return [];
    }
  }

  // Lưu kết quả bài làm
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _firestore.collection('quiz_results').add(result.toMap());
    } catch (e) {
      print('Error saving quiz result: $e');
      throw e;
    }
  }

  // Lấy lịch sử làm bài của user
  Future<List<QuizResult>> getUserQuizHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting quiz history: $e');
      return [];
    }
  }
}

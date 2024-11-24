import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/question.dart';

import 'package:uuid/uuid.dart';
import '../constants/basefires_constant.dart';

class QuestionService extends BaseFirestoreService {
  static const String _collection = 'questions';
  static const String _lessonCollection = 'lesson';

  QuestionService({super.firestore, super.auth});

  Future<void> addQuestion(
    String lessonId,
    String questionText,
    List<String> answers,
    int correctAnswer,
  ) async {
    return handleError(() async {
      final question = Question(
        id: const Uuid().v4(),
        question: questionText,
        answers: answers,
        correctAnswer: correctAnswer,
        createdAt: Timestamp.fromDate(DateTime.now()),
        createdBy: auth.currentUser?.uid ?? '',
      );

      // Use a transaction to ensure data consistency
      await firestore.runTransaction((transaction) async {
        // Add question
        transaction.set(
          firestore.collection(_collection).doc(question.id),
          question.toMap(),
        );

        // Find and update lesson
        final lessonQuery = await firestore
            .collection(_lessonCollection)
            .where('lesson_ID', isEqualTo: int.parse(lessonId))
            .limit(1)
            .get();

        if (lessonQuery.docs.isEmpty) {
          throw Exception('No lesson found with ID: $lessonId');
        }

        transaction.update(
          lessonQuery.docs.first.reference,
          {
            'Question_ID': FieldValue.arrayUnion([question.id]),
          },
        );
      });

      print('Question added successfully to lesson: $lessonId');
    }, 'add question');
  }
}
